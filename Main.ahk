#SingleInstance Force

#Include src\VENV.ahk

Main()

class Main {

    static __New() {
        if this.Prototype.__Class == 'Main' {
            this.Parsers := {
                CallDate: DateObj.Parser('yyyy-MM-dd\``s+H:m:s', '')
              , Duration: DateObj.Parser('H:m:s')
              , Voicemail: DateObj.Parser('MMMM\``s+d\``s+yyyy\``s+a``t\``s+h:m:s\``s+tt', '')
              , Glpi: DateObj.Parser('M/d/yyyy\``s+H:m', '')
              , Attendance: DateObj.Parser('M/d/yyyy\``s+H:m', '')
            }
        }
    }

    static Call() {
        G := this.G := Gui('+Resize')
        Edits := this.Edits := []
        Txts := this.Txts := []
        Btns := this.Btns := []
        Props := ['PathInCalls', 'PathInGroups', 'PathInVoicemails', 'PathInGlpi']
        DefaultPaths := this.DefaultPaths := {}
        W := 0
        for Prop in Props {
            DefaultPaths.%Prop% := ContactsConfig.%Prop%
            Name := StrReplace(Prop, 'PathIn', '')
            if A_Index == 1 {
                Txts.Push(G.Add('Text', 'Section Right vTxt' Prop, Name ':'))
            } else {
                Txts.Push(G.Add('Text', 'xs Section Right vTxt' Prop, Name ':'))
            }
            Txts[-1].GetPos(, , &cw)
            W := Max(W, cw)
        }
        DefaultPaths.PathOut := ContactsConfig.PathOut
        Y := G.MarginY * 2
        for Prop in Props {
            Name := StrReplace(Prop, 'PathIn', '')
            Txts[A_Index].Move(, Y, W)
            Txts[A_Index].GetPos(&cx)
            Edits.Push(G.Add('Edit', Format('x{} y{} w400 r2 -VScroll Section vEdit{}', cx + W + G.MarginX, Y, Prop), A_ScriptDir '\' ContactsConfig.%Prop%))
            Edits[-1].GetPos(, &cy, , &ch)
            Y += ch + G.MarginY
            Btns.Push(G.Add('Button', 'ys vBtn' Prop, 'Select'))
            Btns[-1].Edit := Edits[-1]
            Btns[-1].Prop := Prop
            Btns[-1].OnEvent('Click', HClickButtonGeneral)
            Align.CenterV(Txts[A_Index], Edits[A_Index])
            Align.CenterV(Btns[A_Index], Edits[A_Index])
        }
        Txts.Push(G.Add('Text', Format('x{} y{} w{} Right Section vTxtPathOut', cx, Y + G.MarginY * 2, W), 'Save to:'))
        Edits.Push(G.Add('Edit', 'w400 r2 ys -VScroll vEditPathOut', A_ScriptDir '\' ContactsConfig.PathOut))
        Btns.Push(G.Add('Button', 'ys vBtnPathOut', 'Select'))
        Align.CenterV(Txts[-1], Edits[-1])
        Align.CenterV(Btns[-1], Edits[-1])
        Btns[-1].OnEvent('Click', HClickButtonSelectPathOut)
        Btns[-1].Prop := 'PathOut'
        Btns[-1].Edit := Edits[-1]
        G.Add('Button', 'xs Section vBtnRun', 'Run').OnEvent('Click', HClickButtonRun)
        Btn := G.Add('Button', 'ys Section vBtnOpenOutput', 'Open Output')
        Btn.OnEvent('Click', HClickButtonOpenOutput)
        Btn.Edit := Edits[-1]
        Btn := G.Add('Button', 'ys Section vBtnOpenOutputDir', 'Open Output Dir')
        Btn.OnEvent('Click', HClickButtonOpenOutput)
        Btns.Edit := Edits[-1]
        G.Add('Text', 'ys vTxtStatus', 'Status: Processing')
        G['TxtStatus'].Text := 'Status: Idle'
        Align.CenterV(G['TxtStatus'], G['BtnRun'])

        G.Show()

        HClickButtonGeneral(Ctrl, *) {
            SplitPath(Ctrl.Edit.Text, , &Dir)
            Result := FileSelect('3', Dir || unset, 'Select file')
            if !Result {
                return
            }
            Ctrl.Edit.Text := Result
        }
        HClickButtonOpenOutput(Ctrl, *) {
            if InStr(Ctrl.Name, 'Dir') {
                SplitPath(Ctrl.Edit.Text, , &Dir)
                if Dir {
                    Run('explorer "' Dir '"')
                } else {
                    throw Error('Invalid input.', -1, Ctrl.Edit.Text)
                }
            } else {
                Run('"' Ctrl.Edit.Text '"')
            }
        }
        HClickButtonRun(Ctrl, *) {
            static flag_addtext := true, flag_dots
            flag_dots := true
            for Btn in Btns {
                ContactsConfig.DefineProp(Btn.Prop, { Value: Btn.Edit.Text })
            }
            Ctrl.Gui['TxtStatus'].Text := 'Status: Processing'
            if flag_addtext {
                Ctrl.Gui['TxtStatus'].GetPos(&cx, &cy, &cw)
                Ctrl.Gui.Add('Text', Format('x{} y{} w50 vTxtDots', cx + cw, cy), '.')
                flag_addtext := false
            }
            dots := 0
            SetTimer(_Dots, 500)
            this.Run()
            flag_dots := false
            SetTimer(_Dots, 0)
            Ctrl.Gui['TxtDots'].Text := ''
            Ctrl.Gui['TxtStatus'].Text := 'Status: Complete'

            _Dots(*) {
                if flag_dots {
                    if ++dots > 5 {
                        dots := 1
                    }
                    switch dots {
                        case 1: G['TxtDots'].Text := '.'
                        case 2: G['TxtDots'].Text := '..'
                        case 3: G['TxtDots'].Text := '...'
                        case 4: G['TxtDots'].Text := '....'
                        case 5: G['TxtDots'].Text := '.....'
                    }
                } else {
                    SetTimer(, 0)
                }
            }
        }
        HClickButtonSelectPathOut(Ctrl, *) {
            Initial := Ctrl.Edit.Text ? SubStr(Ctrl.Edit.Text, 1, RegExMatch(Ctrl.Edit.Text, '[\\/][^/\\]+$') - 1) : unset
            Result := FileSelect('S18', Initial ?? unset, 'Select file')
            if !Result {
                return
            }
            Ctrl.Edit.Text := Result
        }
    }

    static Run() {
        IGroups.Parse()
        IContacts.Parse()
        IVoicemails.Parse()
        IGlpi.Parse()
        Results()

        ; sdca := Results.LeftInLobby_SameDayCallsAfter
        ; sdcb := Results.LeftInLobby_SameDayCallsBefore

        Output := (
               'Total answered calls,' Results.Dispisition_Answered.Length
            '`nTotal unanswered calls,' Results.Disposition_Unanswered.Length
            '`nTotal calls before 5:30PM,' Results.Queue_MeetingSupport.Length
            '`nTotal calls after 5:30PM,' Results.Queue_EveningSupport.Length
            '`nUnanswered 15 minutes before groups,' Results.WithinFifteen_Unanswered_Before.Length
            '`nUnanswered 15 minutes after groups,' Results.WithinFifteen_Unanswered_After.Length
            '`nTotal unanswered not within 15 minutes of groups,' Results.NotWithinFifteen_Unanswered.Length
            '`nTotal outbound calls,'
            '`n'
            '`n'
            _GetCategories()
        )
        f := FileOpen(ContactsConfig.PathOut, 'w')
        f.Write(Output)
        f.Close()

        _GetGroupTypes() {
            Str := ''
            for GroupType, Arr in Results.LeftInLobby_GroupTypes {
                Str .= '`n' GroupType ',' Arr.Length
            }
            return Str
        }
        _GetCategories() {
            Str := ''
            for Category, Arr in IGlpi.Notes.Categories {
                if Category != 'Client Support > ' {
                    Category := StrReplace(Category, 'Client Support > ', '')
                }
                if !Category {
                    Category := 'No category'
                }
                Str .= '`n' Category ',' Arr.Length
            }
            return Str
        }
    }
}

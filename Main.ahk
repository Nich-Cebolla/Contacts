#SingleInstance Force

#Include src\VENV.ahk

Main()

class Main {

    static __New() {
        if this.Prototype.__Class == 'Main' {
            this.Parsers := {
                CallDate: DateParser('\t{yyyy-MM-dd}\s+\t{H:m:s}')
              , Duration: DateParser('H:m:s')
              , Voicemail: DateParser('\t{MMMM}\s+\t{d}\s+\t{yyyy}\s+at\s+\t{h:m:s}\s+\t{tt}', 'i)')
              , Glpi: DateParser('\t{M/d/yyyy}\s+\t{H:m}')
              , Attendance: DateParser('\t{M/d/yyyy}\s+\t{H:m}')
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
            Btns[-1].ContentName := Name
            Btns[-1].OnEvent('Click', HClickButtonSelect)
            Align.CenterV(Txts[A_Index], Edits[A_Index])
            Align.CenterV(Btns[A_Index], Edits[A_Index])
        }
        Txts.Push(G.Add('Text', Format('x{} y{} w{} Right Section vTxtPathOut', cx, Y + G.MarginY * 2, W), 'Save to:'))
        Edits.Push(G.Add('Edit', 'w400 r2 ys -VScroll vEditPathOut', A_ScriptDir '\2025-05-output.csv'))
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
        Btn.Edit := Edits[-1]
        G.Add('Text', 'ys vTxtStatus', 'Status: Processing')
        G['TxtStatus'].Text := 'Status: Idle'
        Align.CenterV(G['TxtStatus'], G['BtnRun'])

        G.Show()

        HClickButtonSelect(Ctrl, *) {
            if !this.SelectFile(Ctrl, &Path) {
                Ctrl.Edit.Text := Path
            }
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
            for Btn in this.Btns {
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
            result := this.Run()
            flag_dots := false
            SetTimer(_Dots, 0)
            Ctrl.Gui['TxtDots'].Text := ''
            if result {
                Ctrl.Gui['TxtStatus'].Text := 'Status: Error'
            } else {
                Ctrl.Gui['TxtStatus'].Text := 'Status: Complete'
            }

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
            Initial := Ctrl.Edit.Text
            Result := FileSelect('S2', Initial ?? unset, 'Select file', '*.csv')
            if !Result {
                return
            }
            if DirExist(Result) {
                LastMonth := ContactsConfig.LastMonth
                Result .= '\' LastMonth.Year '-' LastMonth.Month '-output.csv'
            }
            if FileExist(Result) {
                if MsgBox('A file already exists at ' Result '. Is it OK to overwrite?', 'File exists', 'YN') == 'No' {
                    Ctrl.Edit.Text := ''
                } else {
                    Ctrl.Edit.Text := Result
                }
            }
        }
    }

    static CleanupFiles() {
        Content := this.Content := {}
        for btn in this.Btns {
            if InStr(btn.Prop, 'PathOut') {
                continue
            }
            try {
                Content.DefineProp(btn.ContentName, { Value: RegExReplace(FileRead(btn.Edit.Text), '\R', '`n') })
            } catch Error as err {
                problem := err
                problem.Btn := btn
                break
            }
        }
        if IsSet(problem) {
            this.DisplayErrorGui(problem)
            return 1
        }
        Content.Glpi := RegExReplace(Content.Glpi, ',(?=\n|$)', '')
        Content.Voicemails := RegExReplace(Content.Voicemails, ',(?=\n|$)', '')
    }

    static DisplayErrorGui(problem) {
        _str := Strings.ErrorGui
        Config := ContactsConfig.ErrorGui
        if !this.HasOwnProp('EG') {
            ThreadDpiAwarenessContext := DllCall('GetThreadDpiAwarenessContext', 'ptr')
            if Config.ThreadDpiAwarenessContext {
                this.SetThreadDpiAwarenessContext(Config.ThreadDpiAwarenessContext)
            }
            EG := this.EG := Gui('+Resize -DPIScale')
            EG.SetFont(Config.FontOpt)
            EG.Add('Text', 'w' Config.Width ' Section vTxtMain', Format(_str.TxtMain, problem.Btn.Edit.Text))
            EG.Add('Button', 'w' Config.BtnWidth ' xs Section vBtnExit', 'Exit').OnEvent('Click', HClickButtonExit)
            EG.Add('Button', 'w' Config.BtnWidth ' ys vBtnViewError', 'View Error').OnEvent('Click', HClickButtonViewError)
            EG.Add('Button', 'w' Config.BtnWidth ' ys vBtnSelect', 'Select').OnEvent('Click', HClickButtonSelect)
        }
        EG := this.EG
        EG.Problem := problem
        this.G.GetPos(&gx, &gy)
        EG.Show('x' gx ' y' gy)
        if Config.ThreadDpiAwarenessContext {
            this.SetThreadDpiAwarenessContext(ThreadDpiAwarenessContext)
        }

        HClickButtonExit(*) {
            ExitApp()
        }
        HClickButtonViewError(*) {
            Config := ContactsConfig.ErrorGui
            EG := this.EG
            problem := EG.Problem
            StackTraceResult := this.StackTraceResult := StackTraceReader.FromError(problem, 5, 5)
            Width := ContactsConfig.ErrorGui.Width - EG.MarginX * 2
            Obj := StackTraceResult[1]
            for s in StrSplit(Config.FontName, ',') {
                if s {
                    EG.SetFont(, s)
                }
            }
            EG.SetFont(Config.FontOpt)
            EG.Add('Edit', 'w' Width ' r' Config.EdtRows ' xs Section +HScroll -Wrap vEdtError', this.ReadError(problem)).Resizer := { H: 0.5, W: 1 }
            EG.Add('Edit', 'w' Width ' r' Config.EdtRows ' xs Section +HScroll -Wrap vEdtStack', _ReadResult(1)).Resizer := { Y: 0.5, H: 0.5, W: 1 }
            EG['EdtStack'].GetPos(&edtx, &edty, &edtw, &edth)
            this.ItemScroller := ItemScroller(EG, { StartX: edtx, StartY: edty + edth + EG.MarginY, Array: StackTraceResult, Callback: _ItemScroller })
            this.ItemScroller.CtrlBtnNext.GetPos(&btnx, &btny, &btnw, &btnh)
            this.ItemScroller.CtrlBtnback.Resizer := { Y: 1 }
            this.ItemScroller.CtrlEdit.Resizer := { Y: 1 }
            this.ItemScroller.CtrlTxtOf.Resizer := { Y: 1 }
            this.ItemScroller.CtrlTxtTotal.Resizer := { Y: 1 }
            this.ItemScroller.CtrlBtnJump.Resizer := { Y: 1 }
            this.ItemScroller.CtrlBtnNext.Resizer := { Y: 1 }
            EG.Show(Format('w{} h{}', edtx + edtw + EG.MarginX, btny + btnh + EG.MarginY))
            EG.Resizer := GuiResizer(EG, 50)

            sleep 1

        }
        HClickButtonSelect(*) {
            EG := this.EG
            this.SelectFile(this.EG.Problem.Btn, &Path)
            this.EG.Problem.Btn.Edit.Text := Path
            EG.Hide()
        }
        _ItemScroller(Index, Scroller) {
            EG := this.EG
            EG['EdtStack'].Text := _ReadResult(Index)
        }
        _ReadResult(Index) {
            Obj := this.StackTraceResult[Index]
            return RegExReplace('File: ' Obj.Path '`n' 'Line: ' Obj.Line '`nSnippet:`n' Obj.Value, '\R', '`r`n')
        }

    }

    static SelectFile(Ctrl, &Path) {
        if this.G.HasOwnProp('SelectedDirectory') {
            Dir := this.G.SelectedDirectory
        } else {
            if Ctrl.HasOwnProp('Edit') {
                SplitPath(Ctrl.Edit.Text, , &Dir)
            } else {
                Dir := A_ScriptDir
            }
        }
        Result := FileSelect('3', Dir || unset, 'Select file')
        if !Result {
            return 1
        }
        SplitPath(Result, , &Dir)
        this.G.SelectedDirectory := Dir
        Path := Result
    }

    static ReadError(err) {
        return (
            'Message: ' err.message
            '`r`nWhat: ' err.What
            '`r`nFile: ' err.File
            '`r`nLine: ' err.Line
            '`r`nExtra: ' err.Extra
            '`r`nStack:`r`n' err.Stack
        )
    }

    static Run() {
        if this.CleanupFiles() {
            return 1
        }
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

    static SetThreadDpiAwarenessContext(DPI_AWARENESS_CONTEXT) {
        if DllCall('IsValidDpiAwarenessContext', 'ptr', DPI_AWARENESS_CONTEXT, 'uint') {
            return DllCall('SetThreadDpiAwarenessContext', 'ptr', DPI_AWARENESS_CONTEXT, 'ptr')
        }
    }

}

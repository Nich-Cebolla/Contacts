
class IIndividuals {

    static Add(Contact) {
        this.Individuals.AddToList(Contact.CallTo, Contact)
        this.Individuals.AddToList(Contact.CallFrom, Contact)
    }

    static AddVoicemail(Voicemail) {
        Individual := this.Individuals.Get(this.Individuals.Has(Voicemail.PhoneNumber) ? Voicemail.PhoneNumber : 'VM_NoContact')
        return Individual
    }

    class Individuals extends MapExClass {
        static __New() {
            if this.Prototype.__Class == 'IIndividuals.Individuals' {
                this.__Item := Map()
                this.Set('VM_NoContact', IIndividuals.Individual('VM_NoContact'))
            }
        }
        static AddToList(PhoneNumber, Contact) {
            if this.Has(PhoneNumber) {
                this.Get(PhoneNumber).Add(Contact)
            } else {
                this.Set(PhoneNumber, IIndividuals.Individual(PhoneNumber, Contact))
            }
            return this.Get(PhoneNumber)
        }
    }

    class Individual {
        static __New() {
            if this.Prototype.__Class == 'IIndividuals.Individual' {
                this.Prototype.Voicemails := ''
            }
        }

        __New(PhoneNumber, Contact?) {
            this.Outbound := []
            this.Inbound := []
            this.PhoneNumber := PhoneNumber
            if IsSet(Contact) {
                this.Add(Contact)
            }
        }

        Add(Contact) {
            if Contact.CallFrom == this.PhoneNumber {
                this.Outbound.Push(Contact)
            } else if Contact.CallTo == this.Phonenumber {
                this.Inbound.Push(Contact)
            } else {
                throw Error('Unexpected value.', -1, 'CallFrom: ' Contact.CallFrom '; CallTo: ' Contact.CallTo)
            }
        }

        AddVoicemail(Voicemail) {
            if !this.Voicemails {
                this.DefineProp('Voicemails', { Value: [] })
            }
            this.Voicemails.Push(Voicemail)
        }
    }
}

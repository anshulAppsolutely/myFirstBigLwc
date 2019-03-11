import { LightningElement, track, api } from 'lwc';

export default class EmailModal extends LightningElement {
    @track openmodel = false;
    email;
    subject;

    @api
    emailMessage;

    openmodal() {
        this.openmodel = true;
    }
    closeModal() {
        this.openmodel = false;
        /*this.dispatchEvent(
            new CustomEvent('closemodal')
        );*/
    }
    sendEmail(evt) {
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                //inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        if (!allValid) {
            return;
        }
        //alert('save method invoked');
        this.closeModal();
    }

    @api
    openEmail(){
        this.openmodal();
        this.message = this.emailMessage;
    }
}
import { LightningElement, track, api, wire } from 'lwc';
import sendMailMethod from '@salesforce/apex/OwlinEntitiesManagementController.sendMailMethod';
import { showToast } from 'c/utils';
import labelEmail from '@salesforce/label/c.labelEmail';

export default class EmailModal extends LightningElement {
    @track openmodel = false;
    email='';

    @api
    subject;

    @api
    emailMessage;

    label = {
        labelEmail
    };

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
        console.log(' in send js '+this.email +' >>'+ this.emailMessage);
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                //inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        if (!allValid) {
            return;
        }
        sendMailMethod({
            mSubject: this.subject,
            mbody: this.emailMessage,
            recid: this.email
        }).then(() => {
            this.closeModal();
            this.dispatchEvent(
                showToast('Success','dismissable', '', 'Email Sent')
            );
            this.email = ''; this.subject='';
        }).catch((error) => {
            this.dispatchEvent(
                showToast('Error','dismissable', '', error.body.message)
            );
        });

    }

    @api
    openEmail(){
        this.openmodal();
        this.email = '';
    }

    handleEmailKeyUp(evt) {
        this.email = evt.target.value;
    }

    handleSubjectKeyUp(evt) {
        this.subject = evt.target.value;
    }

    handleBodyKeyUp(evt) {
        this.emailMessage = evt.target.value;
    }
}
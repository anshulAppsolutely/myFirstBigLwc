import { LightningElement, track, api, wire } from 'lwc';
import postChatter from '@salesforce/apex/OwlinEntitiesManagementController.postChatter';
import { showToast } from 'c/utils';
import labelChatterPost from '@salesforce/label/c.labelChatterPost';
import Error_ChatterMsg from '@salesforce/label/c.Error_ChatterMsg';

export default class ChatterPostModal extends LightningElement {
    @track opeChatterModel = false;

    @api
    postMessage;

    @api validity = false;

    @api headline;

    label = {
        labelChatterPost,
        Error_ChatterMsg
    };

    @api errorMessage = this.label.Error_ChatterMsg;

    openmodal() {
        this.opeChatterModel = true;
    }

    closeModal() {
        this.opeChatterModel = false;
    }

    postChat(evt) {
        console.log(' in chatter js '+ this.postMessage);
        evt.preventDefault();
        if (!this.postMessage.trim()) {
            this.validity = false;
            return;
        }
        postChatter({
            postMessage: this.postMessage
        }).then(() => {
            this.closeModal();
            this.dispatchEvent(
                showToast('Success', 'dismissable', '', 'Post Success')
            );
        }).catch((error) => {
            this.dispatchEvent(
                showToast('Error', 'dismissable', '', error.body.message)
            );
        });

    }

    @api
    openChatter() {
        console.log('in open chatter modal');
        this.validity = true;
        this.postMessage = this.headline +' '+ this.postMessage
        this.openmodal();
    }


    handleChatterKeyUp(evt) {
        this.postMessage = evt.target.value;
    }
}
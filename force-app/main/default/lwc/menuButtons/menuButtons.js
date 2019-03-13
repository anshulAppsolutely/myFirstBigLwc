import { LightningElement, api } from 'lwc';

export default class MenuButtons extends LightningElement {

    @api
    value;

    @api
    subject;

    get emailVal(){
        return this.value+'$$Email@@'+this.subject;
    }

    get postVal(){
        return this.value+'$$Post@@'+this.subject;
    }

    get taskVal(){
        return this.value+'$$Task@@'+this.subject;
    }

    handleButtonselect(event) {
        event.preventDefault();
        const message = event.detail.value;
        if(message!=undefined && message!=null) {
            this.dispatchEvent(
                new CustomEvent('openmodaltopnews', {detail: message})
            );
        }
    }
}
import { LightningElement, api } from 'lwc';

export default class MenuButtons extends LightningElement {

    @api
    value;

    get emailVal(){
        return this.value+'$$Email';
    }

    get postVal(){
        return this.value+'$$Post';
    }

    get taskVal(){
        return this.value+'$$Task';
    }

    handleButtonselect(event) {
        event.preventDefault();
        console.log('in menu items >>'+event.detail.value);
        let message = event.detail.value;
        console.log('message  >>'+message+' this val  >>'+this.value);
        console.log(typeof message);
        if(message!=undefined && message!=null) {
            let parcedValue = message.split('$$');
            let value = parcedValue[0];
            let label = parcedValue[1];
            console.log('before event >>>'+value+' label >>'+label);
            this.dispatchEvent(
                new CustomEvent('openmodaltopnews', {message: message})
            );
        }
    }
}
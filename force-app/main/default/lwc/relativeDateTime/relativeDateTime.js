import { LightningElement, api} from 'lwc';

export default class RelativeDateTime extends LightningElement {


    @api
    get epochDate() {
        if(this._epochDate!=null && this._epochDate!=''){
            return this._epochDate;
        }
        return '';
    }

    set epochDate(value) {
        console.log('in relative time  >>'+value);
        if(value!=null) {
            var utcSeconds = value;
            var d = new Date(0); // The 0 there is the key, which sets the date to the epoch
            d.setUTCSeconds(utcSeconds);
            this._epochDate = d;
            console.log('in relative time  2>>' + this._epochDate);
        }
    }
}
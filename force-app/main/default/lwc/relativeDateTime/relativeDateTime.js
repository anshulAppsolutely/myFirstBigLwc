import { LightningElement, api} from 'lwc';

export default class RelativeDateTime extends LightningElement {


    @api
    get epochDate() {
        if(this._epochDate!=null && this._epochDate!=''){
            //console.log('in relative time  2>>' + this._epochDate);
            //console.log('in relative time  3>>' + moment(this._epochDate * 1000).fromNow());
            return moment(this._epochDate * 1000).fromNow();
        }
        return '';
    }

    set epochDate(value) {
        //console.log('in relative time  >>'+value);
        if(value!=null) {
            this._epochDate = value;
        }
    }
}
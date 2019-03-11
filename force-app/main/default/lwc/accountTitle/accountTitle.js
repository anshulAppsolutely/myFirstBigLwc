import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class AccountTitle extends NavigationMixin(LightningElement) {

    @api
    get titleColor() {
        return 'color:'+this._titleColor;
    }

    set titleColor(value) {
        this._titleColor = value;
    }

    @api
    get accountsList(){
        return this._accountsList;
    }


    set accountsList(value){
        this._accountsList = value;
    }

    @api
    get entityId(){
        return this._entityId;
    }


    set entityId(value){
        this._entityId = value;
    }

    get accountTitle(){
        // Find matching account by entity ID and navigate.
        var i;
        for (i = 0; i < this._accountsList.length; i++) {
            if (this._entityId === this._accountsList[i].Owlin_Entity_Id__c) {
                    return this._accountsList[i].Name;
            }
        }
    }

    // Find matching account by entity ID and navigate.
    handleClick(event) {
        event.preventDefault();
        event.stopPropagation();
        var i;
        //console.log('clicked >>'+event.target.name+'account list >>'+this._accountsList.length);
        for (i = 0; i < this._accountsList.length; i++) {
            //console.log(this._accountsList[i].Name);
            if (event.target.name === this._accountsList[i].Name) {
                //console.log('id >>'+this._accountsList[i].Id);
                this[NavigationMixin.Navigate]({
                    type: "standard__recordPage",
                    attributes: {
                        recordId: this._accountsList[i].Id,
                        objectApiName: "Account",
                        actionName: "view"
                    }
                });
                return;
            }
            //console.log('here ');
        }
    }

}
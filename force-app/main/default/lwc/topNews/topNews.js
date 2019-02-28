import { LightningElement, track , api, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTopNewsData from '@salesforce/apex/OwlinEntitiesManagementController.getTopNewsData';
// Labels
import Error_Title from '@salesforce/label/c.Error_Title';
import Error_NoData from '@salesforce/label/c.Error_NoData';
import SVG_URL from '@salesforce/resourceUrl/Images';

export default class TopNews extends LightningElement {

    @api
    topNewstitle;

    @api
    tagColor;

    @api
    accountTitleColor;

    @api
    headerColor;

    @api
    topNewsKey;

    @track
    topNewsServer;

    @track
    accounts;

    @track
    loading = true;

    label = {
        Error_Title,
        Error_NoData,
    };

    get headerColorToDisplay () {return 'color:'+this.headerColor}

    get tagColorToDisplay () {return 'background-color:'+this.tagColor}

    poweredBy = SVG_URL + '/owlin/owlinpower.svg';

    /** Get accounts from Apex */
    @wire(getTopNewsData, {filter: '$topNewsKey'})
    wiredTopNewsResponse({ error, data }) {
        if (data) {
            this.loading = false;
            if(data!=null)this.topNewsServer = data.values.slice().sort(this.compareObjects);
            this.accounts = data.accounts;
        } else if (error){
            this.errorToastTopNews(error.body.message);
        }
    }

    compareObjects(a, b){
        return b.event_at - a.event_at;
    }

    /**
     * Show error toast with message
     */
    errorToastTopNews(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: this.topNewstitle +' - '+this.label.Error_Title,
                message: message,
                variant: 'error'
            })
        );
    }

}

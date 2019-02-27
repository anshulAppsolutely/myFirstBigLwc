import { LightningElement, track , api, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTopNewsData from '@salesforce/apex/OwlinEntitiesManagementController.getTopNewsData';
// Labels
import Error_Title from '@salesforce/label/c.Error_Title';
import Error_NoData from '@salesforce/label/c.Error_NoData';

export default class TopNews extends LightningElement {

    @api
    topNewstitle;

    @api
    tagColor;

    @api
    headerColor;

    @api
    topNewsKey;

    @track
    topNewsServer;

    @track
    loading = true;

    label = {
        Error_Title,
        Error_NoData,
    };

    get headerColorToDisplay () {return 'color:'+this.headerColor}

    get tagColorToDisplay () {return 'background-color:'+this.tagColor}

    /** Get accounts from Apex */
    @wire(getTopNewsData, {filter: '$topNewsKey'})
    wiredBubbleResponse({ error, data }) {
        if (data) {
            this.loading = false;
            if(data!=null )this.topNewsServer = data.values;
            console.log('topNewsServer >>');
            var employees= [this.topNewsServer];
            console.log(employees.sort(this.compareObjects));
            //console.log(this.outputProxy(this.topNewsServer));
            //console.log('aaaa '+this.outputProxy(employees));
        } else if (error){
            this.errorToastTopNews(error.body.message);
        }
    }

    //todo check with Dan
    compareObjects(a, b){
        return a.event_at - b.event_at;
    }

    outputProxy(record) {
        var obj = {};
        for(var propt in record) {
            obj[propt] = record[propt];
            if (typeof(record[propt]) == 'object') {
                obj[propt] = this.outputProxy(record[propt]);
            }
        }
        return obj;
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

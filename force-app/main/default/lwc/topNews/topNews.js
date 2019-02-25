import { LightningElement, track , api, wire} from 'lwc';
import getTopNewsData from '@salesforce/apex/OwlinEntitiesManagementController.getTopNewsData';

export default class TopNews extends LightningElement {

    @api
    tagColor;

    @api
    headerColor;

    @api
    statKey;

    @track topNewsServer;

    /** Get accounts from Apex */
    @wire(getTopNewsData)
    wiredBubbleResponse({ error, data }) {
        if (data) {
            this.topNewsServer = data;
        } else if (error) {
            this.errorToast(error.message);
        }
    }


    @track topnews = [

        {
            "score": 425,
            "header": "Eurobank Ergasias : Greece's Eurobank to acquire Grivalia Properties - Eurobank source",
            "url": "marketscreener.com",
            "language": "en",
            "id": "owlin-portfolio:1542708081:b2ce8ccc-1a46-4e6c-83a6-9ec747b334bd_generated:f1599fa1a0a728509186e5f368d4ad41",
            "urlhash": "f1599fa1a0a728509186e5f368d4ad41",
            "epoch": 1543174391,
            "hits": {
                "all": [
                    "acquire"
                ],
                "risk:financial": [
                    "acquire"
                ]
            },
            "cluster_count": 1,
            "cluster_id": "f1599fa1a0a728509186e5f368d4ad41"
        },
        {
            "score": 108,
            "header": "LEON DEPOLAS SECURITIES S.A. - Announcement of acquisition of market making in ?PIRAEUS BANK S.A.? and ?EUROBANK ERGASIAS S.A.?",
            "url": "helex.gr",
            "language": "en",
            "id": "owlin-portfolio:1542708081:b2ce8ccc-1a46-4e6c-83a6-9ec747b334bd_generated:7a658409538d3d2521a11e469d8a95ba",
            "urlhash": "7a658409538d3d2521a11e469d8a95ba",
            "epoch": 1543487700,
            "hits": {
                "all": [
                    "acquisition"
                ],
                "risk:financial": [
                    "acquisition"
                ]
            },
            "cluster_count": 1,
            "cluster_id": "7a658409538d3d2521a11e469d8a95ba"
        }
    ];

    tooltipfunc(){

        //console.log('bbv');
    }

    /**
     * Show error toast with message
     */
    errorToast(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: this.label.Error_Title,
                message: message,
                variant: 'error'
            })
        );
    }

}

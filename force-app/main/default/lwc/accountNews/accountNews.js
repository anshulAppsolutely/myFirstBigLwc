import { LightningElement, api, track } from 'lwc';
import DATA from './accountNewsData';
import DATA2 from './accountNewsData2';


export default class AccountNews extends LightningElement {
    @api
    textColor;

    @api
    title;

    @api
    filter;

    @track
    accountNewsData;

    @track
    loadMoreStatus;

    testSomething;

    columns = [
        {label: 'Header', fieldName: "header", type: 'text'},
        {label: 'Hits', fieldName: 'hits', type: 'text'},
        {label: 'Source', fieldName: 'source', type: 'text'}
    ];

    didScroll = false;

    renderedCallback() {
        // debugger;
        this.accountNewsData = this.formatData(DATA.nodes);

        window.onscroll = function() {
            this.didScroll = true;
        };
    }

    extractHostname(url) {
        var hostname;
        //find & remove protocol (http, ftp, etc.) and get hostname
    
        if (url.indexOf("//") > -1) {
            hostname = url.split('/')[2];
        }
        else {
            hostname = url.split('/')[0];
        }
    
        //find & remove port number
        hostname = hostname.split(':')[0];
        //find & remove "?"
        hostname = hostname.split('?')[0];
    
        return hostname;
    }
    ////

    formatData(input) {
        var i;
        // output = [];
        for (i = 0; i < input.length; i++) {
            input[i].url = input[i].props.url;
            input[i].header = input[i].props.header;
            input[i].hits = (this.filter && input[i].hits && input[i].hits[this.filter] ? input[i].hits[this.filter].join(',') : '');
            input[i].source = this.extractHostname(input[i].props.url);
            // output.push({
            //     url: input[i].props.url,
            //     header: input[i].props.header,
            //     hits: (this.filter && input[i].hits && input[i].hits[this.filter] ? input[i].hits[this.filter].join(',') : ''),
            //     source: this.extractHostname(input[i].props.url)
            // })
        }
        return input;

        // {
        //     "event_at": 1545134283,
        //     "id": "owlin-portfolio:1542708081:7b292322-8d3b-4d28-95d9-c714b2b41b73_generated:335c8258a2c95a2a4381a025fd18c01b",
        //     "key": "335c8258a2c95a2a4381a025fd18c01b",
        //     "props": {
        //       "cluster_count": 1,
        //       "cluster_id": "335c8258a2c95a2a4381a025fd18c01b",
        //       "epoch": 1545134283,
        //       "header": "Grab a fantastic, last-minute mobile phone deal from Vodafone",
        //       "hits": {
        //         "all": []
        //       },
        //       "language": "en",
        //       "url": "https://snewsi.com/id/18483192830/Grab-a-fantastic-last-minute-mobile-phone-deal-from-Vodafone",
        //       "urlhash": "335c8258a2c95a2a4381a025fd18c01b"
        //     },
        //     "shard_id": "57153e87c2a89e988d5f79ad8e1b924762fb15e6",
        //     "stats": {
        //       "all": 1
        //     },
        //     "timeline": "7b292322-8d3b-4d28-95d9-c714b2b41b73_generated",
        //     "version_id": "owlin-portfolio:1542708081"
        //   },
    }

    // loadMoreData: function (event) {
    //     //Display a spinner to signal that data is being loaded
    //     event.target.isLoading = true;
    //     //Display "Loading" when more data is being loaded
    //     this.loadMoreStatus = 'Loading';
    //     fetchData(50)
    //         .then((data) => {
    //             if (data.length >= this.totalNumberOfRows) {
    //                 event.target.enableInfiniteLoading = false;
    //                 this.loadMoreStatus = 'No more data to load';
    //             } else {
                    // const currentData = this.data;
                    // //Appends new data to the end of the table
                    // const newData = currentData.concat(data);
                    // this.data = newData;
                    // this.loadMoreStatus = '';
    //             }
    //             event.target.isLoading = false;
    //         }));
    // }

    handleLoadMore(event) {
        // debugger;
        console.log('loading');
        console.log(this.accountNewsData.length);
        event.target.isLoading = true;
        this.loadMoreStatus = 'Loading';

        const currentData = this.accountNewsData;
        //Appends new data to the end of the table
        const newData = currentData.concat(this.formatData(DATA2.nodes));
        this.accountNewsData = newData;

        // this.accountNewsData = this.accountNewsData.slice().concat(this.formatData(DATA2.nodes));
        this.loadMoreStatus = '';
        event.target.isLoading = false;
        console.log('not loading');
        console.log(this.accountNewsData.length);
    }

}
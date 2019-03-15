import { LightningElement, api, track, wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import MomentAsset from '@salesforce/resourceUrl/moment';
import getAccountNews from '@salesforce/apex/OwlinEntitiesManagementController.getAccountNews';
import { showToast } from 'c/utils';
import D3Asset from '@salesforce/resourceUrl/d3';

import Error_Title from '@salesforce/label/c.Error_Title';
import Error_NoData from '@salesforce/label/c.Error_NoData';

export default class AccountNews extends LightningElement {
    @api
    textColor;

    @api
    title;

    @api
    tagColor;

    @api
    filter;

    @track
    accountNewsData;

    @api
    recordId;

    @api
    totalNumberOfRows = 0;

    @track
    loading = true;

    //max size of rows
    MAX_SIZE = 1000;

    @api
    noOfRecords = 0;

    @track
    displayEntityNews = false;

    label = {
        Error_Title,
        Error_NoData
    };

    get tagColorToDisplay () {return this.tagColor}


    /**
     * ensures that the page loads and renders
     * the container before the graph is created
     */
    didScroll = false;

    renderedCallback() {
        //load the scripts
        Promise.all([
            loadScript(this, MomentAsset + '/moment-with-locales.min.js'),
            loadStyle(this, D3Asset + '/style.css')
        ]).then(() => {
            console.log('didScroll >>'+didScroll);
            window.onscroll = function() {
                this.didScroll = true;
            };
            //do nothing use this in relative time
        }).catch(error => {
            //this impact only a small part relative time. topnews component should be rendered anyways without relative time
        });
    }

    /** Get accounts from Apex */
    @wire(getAccountNews,{ recordId: "$recordId",recordLimit: "$noOfRecords", filter : "$filter" })
    wiredAccountNewsResponse({ error, data }) {
        if (data) {
            if (data === undefined || data.values.length === 0)
            {
                this.displayEntityNews = false;
            } else {
                this.accountNewsData = this.formatData(data.values);
                this.displayEntityNews = true;
            }
            this.loading = false;
        } else if (error) {
            this.loading = false;
            this.error = true;
            this.displayEntityNews = false;
            this.errorToastAccountNews(error.body.message);
        }
    }

    columns = [
        {label: 'Date', fieldName: "epoch", initialWidth: 200, type: 'text'},
        {label: 'Topic header', fieldName: "url", type: 'url',
            typeAttributes: {label: { fieldName: 'header' }, target: '_blank'},
        },
        {label: 'Keywords', fieldName: 'hits', type: 'text',
            cellAttributes:{
                class:{
                    fieldName:'tag'
                },
                iconName: 'utility:trending',
                iconPosition: 'left'
            }
         },
        {label: 'Source', fieldName: 'source', type: 'text'}
    ];


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
        if (hostname.indexOf("www.") > -1) {
            hostname = hostname.split('www.')[1];
        }else{
            hostname = hostname.split(':')[0];
        }
        //find & remove "?"
        hostname = hostname.split('?')[0];
    
        return hostname;
    }
    ////

    formatData(input) {
        input = JSON.parse(input);
        var i;
        var count = 0;
        // output = [];
        for (i = 0; i < input.length; i++) {
            count++;
            input[i].url = input[i].props.url;
            input[i].header = input[i].props.header;
            input[i].hits = (input[i].props.hits && input[i].props.hits[this.filter] ? input[i].props.hits[this.filter].join(', ') : '');
            input[i].source = this.extractHostname(input[i].props.url);
            input[i].epoch = (input[i].props.epoch!=null && input[i].props.epoch!='' ? moment.unix(input[i].props.epoch).format('ddd, MMMM Do  h:mm A'): '');
            input[i].tag = "owlin-keywords";
        }
        this.totalNumberOfRows = count;
        return input;
    }

    loadMoreData(event) {
        //count before loading more
        console.log('previousCount >>'+this.totalNumberOfRows);
        var previousCount = this.totalNumberOfRows;
        if (this.totalNumberOfRows >= this.MAX_SIZE) {
            console.log('im finished >>');
            event.target.enableInfiniteLoading = false;
            event.target.isLoading = false;
        } else {
            console.log('i am getting refresshed');
            this.loading = true;
            //load 20 more
            getAccountNews({
                recordId: this.recordId,
                recordLimit: this.totalNumberOfRows + 100,
                filter : this.filter
            }).then( (data) => {
                var input = this.formatData(data.values);
                console.log('total number of rows in load more >>' + this.totalNumberOfRows);
                this.accountNewsData = input;
                this.loading = false;
            }).catch((error) => {
                this.dispatchEvent(
                    showToast('Error', 'dismissable', '', error.message)
                );
            });
        }
    }

    /**
     * Show error toast with message
     */
    errorToastAccountNews(message) {
        this.dispatchEvent(
            showToast('Error','dismissable',this.title +' - '+this.label.Error_Title, message)
        );
    }

}
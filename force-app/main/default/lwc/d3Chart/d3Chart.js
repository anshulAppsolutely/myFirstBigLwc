import { LightningElement, api, track } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import D3Asset from '@salesforce/resourceUrl/d3';
import MomentAsset from '@salesforce/resourceUrl/moment';
import { NavigationMixin } from 'lightning/navigation';
import { showToast } from 'c/utils';

// Labels
import Error_Title from '@salesforce/label/c.Error_Title';
import Error_NoData from '@salesforce/label/c.Error_NoData';
import Chart_Label_Months from '@salesforce/label/c.Chart_Label_Months';
import Chart_Label_Week from '@salesforce/label/c.Chart_Label_Week';

export default class D3Chart extends NavigationMixin(LightningElement) {
    @api
    recordId;

    d3Initialized = false;

    @api
    title;

    @api
    itemColor;

    @api
    textColor;

    @api
    chartFilter;

    @track
    displayD3 = true;

    @api
    chartData;

    @track
    loading = true;

    label = {
        Error_Title,
        Error_NoData,
        Chart_Label_Week,
        Chart_Label_Months
    };

    @api
    chartMethod;

    /**
     * ensures that the page loads and renders
     * the container before the graph is created
     */
    renderedCallback() {
        if (this.d3Initialized) {
            return;
        }
        this.d3Initialized = true;

        //load the scripts
        Promise.all([
            loadScript(this, D3Asset + '/d3.V5.min.js'),
            loadScript(this, MomentAsset + '/moment-with-locales.min.js'),
            loadStyle(this, D3Asset + '/style.css')
        ]).then(() => {
            //initialize the graph if data created
            this.renderChart(this);
        }).catch(error => {
            //show error if problem in loading d3
            this.dispatchEvent(
                showToast('Error','dismissable', this.title +' - '+ this.label.Error_Title, error.message)
            );
        });
    }

    showChart() {
        this.loading = false;
        this.displayD3 = true;
        d3.select(this.template.querySelector('div.d3'))
        .attr("class", 'd3');
    }

    hideChart() {
        this.loading = false;
        this.displayD3 = false;
        d3.select(this.template.querySelector('div.d3'))
        .attr("class", 'd3 slds-hide');
    }

    renderChart(c) {

        var width, height, svg;

        // bind container object for reference
        var container = c;

        // Do not render prematurely.
        if (!this.chartData || typeof(d3) === 'undefined' || !d3 || typeof(moment) === 'undefined' || !moment) return;

        // Only load if there is something to display.
        if (this.chartData.children.length < 1) {
            container.hideChart();
            return;
        }
        container.showChart();

        // Set the dimensions and margins of the graph
        width = d3.select(this.template.querySelector('div.d3')).node().getBoundingClientRect().width; // Resize based on available width
        height = width * (100 / width); // Fixed aspect

        this.chartMethod(width, height, svg, container);
    }
}
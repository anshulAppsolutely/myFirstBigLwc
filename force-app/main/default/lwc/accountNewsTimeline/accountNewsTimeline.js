import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import D3Asset from '@salesforce/resourceUrl/d3';
import MomentAsset from '@salesforce/resourceUrl/moment';
import { NavigationMixin } from 'lightning/navigation';
import getChartData from '@salesforce/apex/OwlinEntitiesManagementController.getAccountTimeline';

import { showToast } from 'c/utils';

// Labels
import Error_Title from '@salesforce/label/c.Error_Title';
import Error_NoData from '@salesforce/label/c.Error_NoData';
import Chart_Label_Months from '@salesforce/label/c.Chart_Label_Months';
import Chart_Label_Week from '@salesforce/label/c.Chart_Label_Week';


export default class AccountNewsTimeline extends NavigationMixin(LightningElement) {
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
    period;

    @track
    displayD3 = true;

    @track
    chartData;

    @track
    loading = true;

    label = {
        Error_Title,
        Error_NoData,
        Chart_Label_Week,
        Chart_Label_Months
    };

    /** Get accounts from Apex */
    @wire(getChartData, { recordId: "$recordId" })
    wiredResponse({ error, data }) {
        if (error) {
            this.errorToast(error.body.message);
            return;
        }
        if (data === undefined) return;
        if (data.values !== '') {
            this.chartData = { children: JSON.parse(data.values).reverse() };
        } else this.chartData = { children: [] };
        this.renderChart(this);
    }

    formatData(stats_per_hour) {
        // Data is retrieved in hourly grouping and re-grouped on defined period using momentjs:
        let stats_per_day = {}; stats_per_hour.forEach( stat => {
            let k = moment( stat.stats_at * 1000 ).startOf(this.period).unix();
            stats_per_day[k] = stats_per_day[k] || {"stats_at" : k, "stats": {"all" : 0}};
            stats_per_day[k].stats.all += (stat.stats && stat.stats.all ? stat.stats.all : 0);
         });
        return Object.values(stats_per_day);
    }

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
            this.errorToast(error.message);
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

        var width, height, svg, margin, x, y, data;

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
        margin = { top: 20, right: 20, bottom: 30, left: 40 };
        width = width - margin.left - margin.right;
        height = height - margin.top - margin.bottom;

        // Set the ranges
        x = d3.scaleBand()
            .range([0, width])
            .padding(0.1);
        y = d3.scaleLinear()
            .range([height, 0]);
        
        // Build container svg
        svg = d3.select(this.template.querySelector('div.d3 svg'))
            .html("")
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom)
            .append("g")
            .attr("transform",
                "translate(" + margin.left + "," + margin.top + ")");

        // reverse data so that most recent dates are on the right
        data = container.formatData(this.chartData.children);

        // Set the range of both axis
        x.domain(data.map(function (d) {
            return getXLabel(d);
        }));
        y.domain([0, d3.max(data, function (d) { return (d.stats && d.stats.all ? d.stats.all : 0); })]);

        // Add the bars
        svg.selectAll(".bar")
            .data(data)
            .enter().append("rect")
            .attr("class", "bar")
            .attr('fill', this.itemColor)
            .attr("x", function (d) { return x(getXLabel(d)); })
            .attr("width", x.bandwidth())
            .attr("y", function (d) { return d.stats && d.stats.all ? y(d.stats.all) : 0; })
            .attr("height", function (d) { return height - (d.stats && d.stats.all ? y(d.stats.all) : 0); })
            .on('click', function (d) { container.clickAction(d.stats_at) }); // Add onclick action binding

        // add the x Axis
        svg.append("g")
            .attr("transform", "translate(0," + height + ")")
            .call(d3.axisBottom(x))

        // add the y Axis
        svg.append("g")
            .attr("class", "yaxis")
            .call(d3.axisLeft(y).tickFormat(d3.format(".0s")).ticks(3));

        // Remove some ticks (we only want whole numbers on this chart)
        // d3.selectAll('g.yaxis .tick').each(function (d, i) {
        //     if (d !== Math.round(d))
        //         d3.select(this).remove()
        // });

        // Build correct output for dates
        // @todo labels (month names + Wk)
        function getXLabel(d) {
            var yearStart, weekNo, clonedDate;
            var monthNames = container.label.Chart_Label_Months.split(',');
            var thisDate = new Date(d.stats_at * 1000);
            if (container.period === 'week') {
                // Calcuate week number from date;
                clonedDate = new Date(Date.UTC(thisDate.getFullYear(), thisDate.getMonth(), thisDate.getDate()));
                clonedDate.setUTCDate(clonedDate.getUTCDate() + 4 - (clonedDate.getUTCDay() || 7));
                yearStart = new Date(Date.UTC(clonedDate.getUTCFullYear(), 0, 1));
                weekNo = Math.ceil((((clonedDate - yearStart) / 86400000) + 1) / 7);
                return container.label.Chart_Label_Week + ' ' + weekNo;
            }
            if (container.period === 'day') // get day and month
                return thisDate.getDate() + ' ' + monthNames[thisDate.getMonth()];
            // Return month and year
            return monthNames[thisDate.getMonth()] + ' ' + thisDate.getFullYear();
        }
    }

    // @todo Fire event to navigate Account News to correct timestamp.
    clickAction(key) {
        //console.log(key)
    }

    /** 
     * Show error toast with message 
     */
    errorToast(message) {
        this.dispatchEvent(
            showToast('Error','dismissable', this.title +' - '+ this.label.Error_Title, message)
        );
    }


}
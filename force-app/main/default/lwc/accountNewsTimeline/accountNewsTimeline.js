import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import D3 from '@salesforce/resourceUrl/d3';
import { NavigationMixin } from 'lightning/navigation';
import getChartData from '@salesforce/apex/OwlinEntitiesManagementController.getAccountTimeline';

// Labels
import Error_Title from '@salesforce/label/c.Error_Title';
import Error_NoData from '@salesforce/label/c.Error_NoData';

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
    statKey;

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
    };

    /** Get accounts from Apex */
    @wire(getChartData, { recordId: "$recordId" })
    wiredBubbleResponse({ error, data }) {
        if (data) {
            console.log(data.values);
            this.chartData = { children: JSON.parse(data.values) };
            this.renderChart(this);
        } else if (error) {
            this.errorToast(error.body.message);
        }
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
            loadScript(this, D3 + '/d3.V5.min.js'),
            loadStyle(this, D3 + '/style.css'),
        ]).then(() => {
            //initialize the graph if data created
            this.renderChart(this);
        }).catch(error => {
            //show error if problem in loading d3
            this.errorToast(error.message);
        });
    }



    renderChart(c) {

        var width, height, tooltip, bubble, svg, nodes, node, margin, parseDate;

        // bind container object for reference
        var container = c;

        if (!this.chartData || !d3) return;

        this.loading = false;
        if (this.chartData.length < 1) {
            this.displayD3 = false;
            return;
        }
        this.displayD3 = true;

        width = d3.select(this.template.querySelector('div.d3')).node().getBoundingClientRect().width; // Resize based on available width
        height = width * (100 / width); // Fixed aspect

        // set the dimensions and margins of the graph
        var margin = { top: 20, right: 20, bottom: 30, left: 40 },
            width = width - margin.left - margin.right,
            height = height - margin.top - margin.bottom;

        // set the ranges
        var x = d3.scaleBand()
            .range([0, width])
            .padding(0.1);
        var y = d3.scaleLinear()
            .range([height, 0]);//.tickFormat(d3.format("d"));

        // append the svg object to the body of the page
        // append a 'group' element to 'svg'
        // moves the 'group' element to the top left margin
        var svg = d3.select(this.template.querySelector('div.d3')).append("svg")
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom)
            .append("g")
            .attr("transform",
                "translate(" + margin.left + "," + margin.top + ")");

        var data = this.chartData.children;
        // format the data
        // data.forEach(function (d) {
        //     d.sales = +d.sales;
        // });

        const monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
            "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
        ];


        // Scale the range of the data in the domains
        x.domain(data.map(function (d) {
            var thisDate = new Date(d.stats_at * 1000);
            if (container.period === 'week')
                return getWeekNumber(thisDate); //
            if (container.period === 'day')
                return thisDate.getDate() + monthNames[thisDate.getMonth()];
            return d.stats_at;
        }));
        y.domain([0, d3.max(data, function (d) { return d.stats.all; })]);

        // append the rectangles for the bar chart
        svg.selectAll(".bar")
            .data(data)
            .enter().append("rect")
            .attr("class", "bar")
            .attr('fill', this.itemColor)
            .attr("x", function (d) { return x(d.stats_at); })
            .attr("width", x.bandwidth())
            .attr("y", function (d) { return y(d.stats.all); })
            .attr("height", function (d) { return height - y(d.stats.all); })
            .on('click', function (d) { container.clickAction(d.stats_at) });

        // add the x Axis
        svg.append("g")
            .attr("transform", "translate(0," + height + ")")
            .call(d3.axisBottom(x))

        // add the y Axis
        svg.append("g")
            .attr("class", "yaxis")
            .call(d3.axisLeft(y).tickFormat(d3.format(".0s")));

        d3.selectAll('g.yaxis .tick').each(function (d, i) {
            if (d !== Math.round(d))
                d3.select(this).remove()
        });

        function getWeekNumber(d) {
            // Copy date so don't modify original
            d = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()));
            // Set to nearest Thursday: current date + 4 - current day number
            // Make Sunday's day number 7
            d.setUTCDate(d.getUTCDate() + 4 - (d.getUTCDay() || 7));
            // Get first day of year
            var yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
            // Calculate full weeks to nearest Thursday
            var weekNo = Math.ceil((((d - yearStart) / 86400000) + 1) / 7);
            // Return array of year and week number
            return [d.getUTCFullYear(), weekNo];
        }

    }

    clickAction(key) {
        //console.log(key)
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
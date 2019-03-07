import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getChartData from '@salesforce/apex/OwlinEntitiesManagementController.getAccountTimeline';
import { showToast } from 'c/utils';
// Labels
import Error_Title from '@salesforce/label/c.Error_Title';
import Error_NoData from '@salesforce/label/c.Error_NoData';
import Error from '@salesforce/label/c.Error';

export default class AccountNewsTimeline extends NavigationMixin(LightningElement) {
    @api
    recordId;

    @api
    title;

    @api
    itemColor;

    @api
    textColor;

    @api
    chartLimit;

    @api
    chartFilter;

    @track
    chartData;

    @track
    error = false;

    label = {
        Error_Title,
        Error_NoData,
        Error
    };

    /**
     * Define the logic to build the chart from the available data
     */
    @track chartMethod = function(width, height, svg, container) {
            
        var data, x, y, margin;

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
        data = formatData(container.chartData.children);

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
            .on('click', function (d) { clickAction(d.stats_at) }); // Add onclick action binding

        // add the x Axis
        svg.append("g")
            .attr("transform", "translate(0," + height + ")")
            .call(d3.axisBottom(x))

        // add the y Axis
        svg.append("g")
            .attr("class", "yaxis")
            .call(d3.axisLeft(y).tickFormat(d3.format(".0s")).ticks(3));

        //Remove some ticks (we only want whole numbers on this chart)
        d3.selectAll('g.yaxis .tick').each(function (d, i) {
            if (d !== Math.round(d))
                d3.select(this).remove()
        });

        // Build correct output for dates
        function getXLabel(d) {
            if (container.chartFilter === 'week') {
                return container.label.Chart_Label_Week + ' ' + moment(d.stats_at * 1000 ).startOf(container.chartFilter).week();
            }
            if (container.chartFilter === 'day') // get day and month
                return moment(d.stats_at * 1000).startOf(container.chartFilter).format('D MMM');
            // Return month and year
            return moment(d.stats_at * 1000).startOf(container.chartFilter).format('MMM YY');
        }

        function formatData(stats_per_hour) {
            // Data is retrieved in hourly grouping and re-grouped on defined period using momentjs:
            let stats_per_day = {}; stats_per_hour.forEach( stat => {
                let k = moment( stat.stats_at * 1000 ).startOf(container.chartFilter).unix();
                stats_per_day[k] = stats_per_day[k] || {"stats_at" : k, "stats": {"all" : 0}};
                stats_per_day[k].stats.all += (stat.stats && stat.stats.all ? stat.stats.all : 0);
             });
            return Object.values(stats_per_day).slice(0,container.chartLimit);
        }

        // @todo Fire event to navigate Account News to correct timestamp.
        function clickAction(key) {
            console.log(key)
        }
    }

    /** Get data from Apex */
    @wire(getChartData, { recordId: "$recordId" })
    wiredResponse({ error, data }) {
        if (error) {
            this.dispatchEvent(
                showToast('Error','dismissable', this.title +' - '+ this.label.Error_Title, error.body.message)
            );
            this.error = true;
            return;
        }
        if (data === undefined) return;
        if (data.values !== '') {
            this.chartData = { children: JSON.parse(data.values).reverse() };
        } else this.chartData = { children: [] };
    }
}
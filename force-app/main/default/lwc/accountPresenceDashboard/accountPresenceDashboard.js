import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getAccountForBubble from '@salesforce/apex/OwlinEntitiesManagementController.getAccountForBubble';
import { showToast } from 'c/utils';

// Labels
import Error_Title from '@salesforce/label/c.Error_Title';
import Error_NoData from '@salesforce/label/c.Error_NoData';
import Error from '@salesforce/label/c.Error';

export default class AccountPresenceDashboard extends NavigationMixin(LightningElement) {

    @api
    title;

    @api
    itemColor;

    @api
    textColor;

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

    /** Get accounts from Apex */
    @wire(getAccountForBubble)
    wiredBubbleResponse({ error, data }) {
        if (data) {
            this.chartData = { children: JSON.parse(data.values), accounts: data.accounts };
        } else if (error) {
            this.dispatchEvent(
                showToast('Error', 'dismissable', this.title + ' - ' + this.label.Error_Title, error.body.message)
            );
            this.error = true;
        }
    }

    @track
    chartMethod = function (width, height, svg, container) {

        var tooltip, bubble, nodes, node;

        if (!this.chartData || !d3) return;

        if (bubblesToDisplay(this.chartData, this.chartFilter) < 1) {
            container.hideChart();
            return;
        }
        container.showChart();

        height = width * (400 / width); // Fixed aspect

        tooltip = d3.select("body")
            .append("div")
            .style("position", "absolute")
            .style("z-index", "10")
            .style("visibility", "hidden")
            .style("color", "white")
            .style("padding", "8px")
            .style("background-color", "rgba(0, 0, 0, 0.75)")
            .style("border-radius", "6px")
            .style("font", "12px sans-serif")
            .text("tooltip");

        bubble = d3.pack(this.chartData)
            .size([width, height]);

        // Add SVG to render bubble chart
        svg = d3.select(this.template.querySelector('div.d3 svg'))
            .html("")
            .attr("width", width)
            .attr("height", height)

        // Build nodes
        nodes = d3.hierarchy(this.chartData)
            .sum(function (d) {
                return getValue(d);
            });

        // For each node, populate with bubble
        node = svg.selectAll(".node")
            .data(bubble(nodes).descendants())
            .enter()
            .filter(function (d) {
                return !d.children
            })
            .append("g")
            .attr("class", "node clickable")
            .attr("transform", function (d) {
                return "translate(" + (d.x ? d.x : 0) + "," + (d.y ? d.y : 0) + ")";
            });


        node.append("circle")
            .attr("r", function (d) {
                return (d.r ? d.r : 0);
            })
            .style("fill", this.itemColor);

        node.append("text")
            .attr("dy", ".2em")
            .style("text-anchor", "middle")
            .text(function (d) {
                return getTitle(d.data);
            })
            .attr("font-family", "sans-serif")
            .attr("font-size", function (d) {
                return getTitleRadius(d.r, getTitle(d.data));
            })
            .attr("fill", this.textColor);

        // Handle click on node
        node.on('click', function (d) { navigateToAccount(d.data.key) });

        // Populate tooltip with title text
        node.on("mouseover", function (d) {
            tooltip.text(d.data.title);
            tooltip.style("visibility", "visible");
        })
            .on("mousemove", function () {
                return tooltip.style("top", (d3.event.pageY - 30) + "px").style("left", (d3.event.pageX + 10) + "px");
            })
            .on("mouseout", function () { return tooltip.style("visibility", "hidden"); });

        // Get appropriate value for account (bubble size)
        function getValue(d) {
            return d.stats && d.stats[container.chartFilter] !== undefined ? d.stats[container.chartFilter].value : 0;
        }

        // Get title for account
        function getTitle(d) {
            var title = d.title;
            if (title.length < 5) return title;
            return title.split(' ').map((part, index) => {
                if (index > 0) return part.replace(/[^a-zA-Z0-9]/g, '').substr(0, 1) + '.';
                else if (part.length > 12) return part.substr(0, 8) + '.';
                return part;
            }).join(' ');
        }

        function getTitleRadius(radius, title, max = 30) {
            const SIZES = {
                w: 1.5,
                m: 1.5,
                i: 0.6,
                l: 0.6,
                '1': 0.7,
                '.': 0.2,
                ',': 0.2
            };

            var l = 0;
            var chr, s, i;
            for (i = 0; i < title.length; i++) {
                // get character
                chr = title.substr(i, 1);
                // get estimate of character width
                s = SIZES[chr.toLowerCase()] || 1;
                // uppercase is bigger
                if (chr.toUpperCase() === chr) s = s + 0.3;
                l = l + s;
            }
            return Math.min(max, (2.5 * radius) / l);
        }

        function bubblesToDisplay(chartData, chartFilter) {
            var i;
            var toDisplay = 0;
            for (i = 0; i < chartData.children.length; i++) {
                if (chartData.children[i].stats[chartFilter] && chartData.children[i].stats[chartFilter].value > 0) {
                    toDisplay++;
                }
            }
            return toDisplay;
        }

        // Find matching account by entity ID and navigate.
        function navigateToAccount(entityId) {
            var i;
            for (i = 0; i < container.chartData.accounts.length; i++) {
                if (entityId === container.chartData.accounts[i].Owlin_Entity_Id__c) {
                    container[NavigationMixin.Navigate]({
                        type: "standard__recordPage",
                        attributes: {
                            recordId: container.chartData.accounts[i].Id,
                            objectApiName: "Account",
                            actionName: "view"
                        }
                    });
                    return;
                }
            }
            container.errorToast('Could not find matching account.'); //@todo label
        }
    }

    /** 
     * Show error toast with message 
     */
    errorToast(message) {
        this.dispatchEvent(
            showToast('Error', 'dismissable', this.title + ' - ' + this.label.Error_Title, message)
        );
    }
}
import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import D3 from '@salesforce/resourceUrl/d3';
import { NavigationMixin } from 'lightning/navigation';
import getAccountForBubble from '@salesforce/apex/OwlinEntitiesManagementController.getAccountForBubble';

// Labels
import Error_Title from '@salesforce/label/c.Error_Title';
import Error_NoData from '@salesforce/label/c.Error_NoData';

export default class AccountPresenceDashboard extends NavigationMixin(LightningElement) {

    d3Initialized = false;

    @api
    title;

    @api
    bubbleColor;

    @api
    textColor;

    @api
    statKey;

    @track accounts;
    bubbleData;

    @track
    displayD3 = true;
    
    @track
    loading = true;

    label = {
        Error_Title,
        Error_NoData,
    };

    /** Get accounts from Apex */
    @wire(getAccountForBubble)
    wiredBubbleResponse({ error, data }) {
        if (data) {
            this.accounts = data.accounts;
            this.bubbleData = {children: JSON.parse(data.values)};
            this.bubbleChart(this);
        } else if (error) {
            this.errorToast(error.body.message);
            this.accounts = undefined;
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
            //initialize the graph if accounts created
            this.bubbleChart(this);
        }).catch(error => {
            //show error if problem in loading d3
            this.errorToast(error.message);
        });
    }

    bubbleChart(c) {
        var width, height, tooltip, bubble, svg, nodes, node;
        
        // bind container object for reference
        var container = c;

        if(!this.bubbleData || !d3) return;
        
        this.loading = false;
        if(this.bubbleData.children.length < 1 || bubblesToDisplay(this.bubbleData, this.statKey) < 1){
            this.displayD3 = false;
            return;
        } 
        this.displayD3 = true;

        width = d3.select(this.template.querySelector('div.d3')).node().getBoundingClientRect().width; // Resize based on available width
        height = width * (400/width); // Fixed aspect

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

        bubble = d3.pack(this.bubbleData)
            .size([width, height]);

        // Add SVG to render bubble chart
        svg = d3.select(this.template.querySelector('div.d3'))
            .append('svg')
            .attr("width", width)
            .attr("height", height)

        // Build nodes
        nodes = d3.hierarchy(this.bubbleData)
            .sum(function(d) {
                return getValue(d);
            });

        // For each node, populate with bubble
        node = svg.selectAll(".node")
            .data(bubble(nodes).descendants())
            .enter()
            .filter(function(d){
                return  !d.children
            })
            .append("g")
            .attr("class", "node")
            .attr("transform", function(d) {
                return "translate(" + (d.x ? d.x : 0) + "," + (d.y ? d.y : 0) + ")";
            });


        node.append("circle")
            .attr("r", function(d) {
                return (d.r ? d.r : 0);
            })
            .style("fill", this.bubbleColor);

        node.append("text")
            .attr("dy", ".2em")
            .style("text-anchor", "middle")
            .text(function(d) {
                return getTitle(d.data);
            })
            .attr("font-family", "sans-serif")
            .attr("font-size", function(d){
                return getTitleRadius(d.r, getTitle(d.data));
            })
            .attr("fill", this.textColor);
        
        // Handle click on node
        node.on('click', function (d) {container.navigateToAccount(d.data.key)});

        // Populate tooltip with title text
        node.on("mouseover", function(d) {
            tooltip.text(d.data.title);
            tooltip.style("visibility", "visible");
            })
            .on("mousemove", function() {
                return tooltip.style("top", (d3.event.pageY-30)+"px").style("left",(d3.event.pageX+10)+"px");
            })
            .on("mouseout", function(){return tooltip.style("visibility", "hidden");});

        // Get appropriate value for account (bubble size)
        function getValue(d) {
            return d.stats && d.stats[container.statKey] !== undefined ? d.stats[container.statKey].value : 0;
        }

        // Get title for account
        function getTitle(d){
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

        function bubblesToDisplay(bubbleData, statKey) {
            var i;
            var toDisplay = 0;
            for (i = 0; i < bubbleData.children.length; i ++) {
                if (bubbleData.children[i].stats[statKey] && bubbleData.children[i].stats[statKey].value > 0) {
                    toDisplay++;
                }
            }
            return toDisplay;
        }
    }

    // Find matching account by entity ID and navigate.
    navigateToAccount(entityId) {
        var i;
        for (i = 0; i < this.accounts.length; i++) {
            if (entityId === this.accounts[i].Owlin_Entity_Id__c) {
                this[NavigationMixin.Navigate]({
                    type: "standard__recordPage",
                    attributes: {
                        recordId: this.accounts[i].Id,
                        objectApiName: "Account",
                        actionName: "view"
                    }
                });
                return;
            }
        }
        this.errorToast('Could not find matching account.');
    }

    /** 
     * Show error toast with message 
     */ 
    errorToast(message) {
        //console.log('message >>'+message);
        this.dispatchEvent(
            new ShowToastEvent({
                title: this.title +' - '+this.label.Error_Title,
                message: message,
                variant: 'error'
            })
        );
    }
}
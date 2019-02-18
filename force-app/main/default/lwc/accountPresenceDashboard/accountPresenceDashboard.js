import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import D3 from '@salesforce/resourceUrl/d3';
// import DATA from './data';
// import Selector from '@salesforce/schema/EmailDomainKey.Selector';
// import { getFieldValue } from 'lightning/uiRecordApi';
// import UserPreferencesShowTitleToExternalUsers from '@salesforce/schema/UserChangeEvent.UserPreferencesShowTitleToExternalUsers';
import { NavigationMixin } from 'lightning/navigation';

//import DATASET from './account-presence-response';
import getAccountForBubble from '@salesforce/apex/OwlinEntitiesManagementController.getAccountForBubble';
import getUserAccountList from '@salesforce/apex/OwlinEntitiesManagementController.getUserAccountList';


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
    DATASET = [];

    /** Get accounts from Apex */
    @wire(getUserAccountList)
    wiredAccounts({ error, data }) {
        if (data) {
            this.accounts = data;
            // this.outputProxy(data);
        } else if (error) {
            this.errorToast(error.body.message);
            this.accounts = undefined;
        }
    }

    /** Get accounts from Apex */
    @wire(getAccountForBubble)
    wiredBubbleResponse({ error, data }) {
        console.log('1 executed >'+data);
        if (data) {
            this.DATASET.push(data);
            this.bubbleChart(this);
            // this.outputProxy(data);
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
            console.log('2 executed >'+this.DATASET);
            //initialize the graph if accounts created

        }).catch(error => {
            //show error if problem in loading d3
            this.errorToast(error.message);
        });
    }

    bubbleChart(c) {
        // bind container object for reference
        var container = c;

        var width = d3.select(this.template.querySelector('div.d3')).node().getBoundingClientRect().width; // Resize based on available width
        var height = width * 0.4; // Fixed aspect

        //@todo replace DATASET with live response from Owlin
        var bubble = d3.pack(DATASET)
            .size([width, height]);

        // Add SVG to render bubble chart
        var svg = d3.select(this.template.querySelector('div.d3'))
            .append('svg')
            .attr("width", width)
            .attr("height", height)

        // Build nodes
        var nodes = d3.hierarchy(DATASET)
            .sum(function(d) {
                return getValue(d);
            });

        // For each node, populate with bubble
        var node = svg.selectAll(".node")
            .data(bubble(nodes).descendants())
            .enter()
            .append("g")
            .attr("class", "node")
            .attr("transform", function(d) {
                return "translate(" + d.x + "," + d.y + ")";
            });
        
        node.append("title")
            .text(function(d) {
                return d.data.title;
            });

        node.append("circle")
            .attr("r", function(d) {
                return d.r;
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
            .attr("fill", this.textColor)
        
        // Handle click on node
        node.on('click', function (d) {container.navigateToAccount(d.data.key)});

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
     * @todo labels
     */ 
    errorToast(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: message,
                variant: 'error'
            })
        );
    }

    /** this is just a helper method for development. */
    outputProxy(record) {
        var obj = {};
        for(var propt in record) {
            obj[propt] = record[propt];
            if (typeof(record[propt]) == 'object') {
                obj[propt] = this.outputProxy(record[propt]);
            }
        }
        console.log(obj);
        return obj;
    }

    /**
     * method used to initialize graph (old chart - to delete)
     */
    /*initializeD3() {

        //get the reference container through svg
        const svg = d3.select(this.template.querySelector('svg.d3'));
        const width = this.svgWidth;
        const height = this.svgHeight;
        const color = d3.scaleOrdinal(d3.schemeDark2);

        const simulation = d3
            .forceSimulation()
            .force(
                'link',
                d3.forceLink().id(d => {
                    return d.id;
                })
            )
            .force('charge', d3.forceManyBody())
            .force('center', d3.forceCenter(width / 2, height / 2));

        const link = svg
            .append('g')
            .attr('class', 'links')
            .selectAll('line')
            .data(DATA.links)
            .enter()
            .append('line')
            .attr('stroke-width', d => {
                return Math.sqrt(d.value);
            });

        const node = svg
            .append('g')
            .attr('class', 'nodes')
            .selectAll('circle')
            .data(DATA.nodes)
            .enter()
            .append('circle')
            .attr('r', 10)
            .attr('fill', d => {
                return color(d.group);
            })
            .call(d3
                .drag()
                .on('start', dragstarted)
                .on('drag', dragged)
                .on('end', dragended)
            );

        node.append('title')
            .text(function(d) {
                return d.id;
        });

        node.on('click', function(d,i) {
            alert(DATA.nodes[i].id);

        });

        simulation.nodes(DATA.nodes).on('tick', ticked);

        simulation.force('link').links(DATA.links);

        function ticked() {
            link.attr('x1', d => d.source.x)
        .attr('y1', d => d.source.y)
        .attr('x2', d => d.target.x)
        .attr('y2', d => d.target.y);
            node.attr('cx', d => d.x).attr('cy', d => d.y);
        }

        function dragstarted(d) {
            if (!d3.event.active) {
                simulation.alphaTarget(0.3).restart();
            }
            d.fx = d.x;
            d.fy = d.y;
        }

        function dragged(d) {
            d.fx = d3.event.x;
            d.fy = d3.event.y;
        }

        function dragended(d) {
            if (!d3.event.active) {
                simulation.alphaTarget(0);
            }
            d.fx = null;
            d.fy = null;
        }
    } */
}
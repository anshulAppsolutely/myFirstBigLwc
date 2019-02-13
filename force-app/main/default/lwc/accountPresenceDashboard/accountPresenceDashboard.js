import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import D3 from '@salesforce/resourceUrl/d3';
// import DATA from './data';
// import Selector from '@salesforce/schema/EmailDomainKey.Selector';
// import { getFieldValue } from 'lightning/uiRecordApi';
// import UserPreferencesShowTitleToExternalUsers from '@salesforce/schema/UserChangeEvent.UserPreferencesShowTitleToExternalUsers';
import { NavigationMixin } from 'lightning/navigation';

import DATASET from './account-presence-response'; 
import getAccountList from '@salesforce/apex/OwlinEntitiesManagementController.getAccountList';


export default class AccountPresenceDashboard extends NavigationMixin(LightningElement) {

    d3Initialized = false;
    scriptsImported = false;

    @api
    bubbleColor;

    @api
    textColor;

    @api
    statKey = 'delta:month';
    
    @track accounts;

    /** Get accounts from Apex */
    @wire(getAccountList)
    wiredAccounts({ error, data }) {
        if (data) {
            this.accounts = data;
            // this.outputProxy(data);
            //initialize the graph if scripts imported
            if (this.scriptsImported) 
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
            loadStyle(this, D3 + '/style.css')
        ]).then(() => {
            //initialize the graph if accounts created
            if (this.accounts)
                this.bubbleChart(this);

        }).catch(error => {
            //show error if problem in loading d3
            this.errorToast(error.message);
        });
    }

    bubbleChart(c) {
        // bind container object for reference
        var container = c;

        var width = d3.select(this.template.querySelector('div.d3')).node().getBoundingClientRect().width; // Resize based on available width
        var height = width * 0.6; // Fixed aspect

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
            .filter(function(d){
                return  !d.children
            })
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
                return d.r/5;
            })
            .attr("fill", this.textColor)
        
        // Handle click on node
        node.on('click', function (d) {container.navigateToAccount(d.data.key)});

        // Get appropriate value for account (bubble size)
        function getValue(d) {
            var statKey = 'delta:month';
            return d.stats && d.stats[statKey] !== undefined ? d.stats[statKey].value : 0;
        }

        // Get title for account
        function getTitle(d){
            // d.data.title.substring(0, d.r / 3)
            return d.title.substring(0,10);
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
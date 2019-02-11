import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import D3 from '@salesforce/resourceUrl/d3';
import DATA from './data';

export default class AccountPresenceDashboard extends LightningElement {

    d3Initialized = false;

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
            //initialize the graph
            this.bubbleChart();

        }).catch(error => {
            //show error if problem in loading d3
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading D3',
                    message: error.message,
                    variant: 'error'
                })
            );
        });
    }

    bubbleChart() {

        var dataset = {
            "children": [{"Name":"Olives","Count":4319},
                {"Name":"Tea","Count":4159},
                {"Name":"Mashed Potatoes","Count":2583},
                {"Name":"Boiled Potatoes","Count":2074},
                {"Name":"Milk","Count":1894},
                {"Name":"Chicken Salad","Count":1809},
                {"Name":"Vanilla Ice Cream","Count":1713},
                {"Name":"Cocoa","Count":1636},
                {"Name":"Lettuce Salad","Count":1566},
                {"Name":"Lobster Salad","Count":1511},
                {"Name":"Chocolate","Count":1489},
                {"Name":"Apple Pie","Count":1487},
                {"Name":"Orange Juice","Count":1423},
                {"Name":"American Cheese","Count":1372},
                {"Name":"Green Peas","Count":1341},
                {"Name":"Assorted Cakes","Count":1331},
                {"Name":"French Fried Potatoes","Count":1328},
                {"Name":"Potato Salad","Count":1306},
                {"Name":"Baked Potatoes","Count":1293},
                {"Name":"Roquefort","Count":1273},
                {"Name":"Stewed Prunes","Count":1268}]
        };
        
        var width = d3.select(this.template.querySelector('div.d3')).node().getBoundingClientRect().width; // Resize based on available width
        var height = width * 0.6; // Fixed aspect
        
        var color = d3.scaleOrdinal(d3.schemeCategory10);

        var bubble = d3.pack(dataset)
            .size([width, height])
            .padding(1.5);

        var svg = d3.select(this.template.querySelector('div.d3')).append('svg')
            .attr("width", width)
            .attr("height", height)
            .attr("class", "bubble");

        var nodes = d3.hierarchy(dataset)
            .sum(function(d) { return d.Count; });

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
                return d.Name + ": " + d.Count;
            });

        node.append("circle")
            .attr("r", function(d) {
                return d.r;
            })
            .style("fill", function(d,i) {
                return color(0); // pass i to change colour on each bubble
            });

        node.append("text")
            .attr("dy", ".2em")
            .style("text-anchor", "middle")
            .text(function(d) {
                return d.data.Name.substring(0, d.r / 3);
            })
            .attr("font-family", "sans-serif")
            .attr("font-size", function(d){
                return d.r/5;
            })
            .attr("fill", "white");

        node.append("text")
            .attr("dy", "1.3em")
            .style("text-anchor", "middle")
            .text(function(d) {
                return d.data.Count;
            })
            .attr("font-family",  "Gill Sans", "Gill Sans MT")
            .attr("font-size", function(d){
                return d.r/5;
            })
            .attr("fill", "white");

        d3.select(self.frameElement)
            .style("height", height + "px");
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
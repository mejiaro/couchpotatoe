// vim: ts=2 sw=2
(function () {
    d3.timeline = function() {
        var DISPLAY_TYPES = ["circle", "rect"];

        var hover = function () {},
            mouseover = function () {},
            mouseout = function () {},
            click = function () {},
            scroll = function () {},
            orient = "bottom",
            width = null,
            height = null,
            rowSeperatorsColor = 'black',
            backgroundColor = null,
            tickFormat = { format: d3.time.format("%I %p"),
                tickTime: d3.time.hours,
                tickInterval: 1,
                tickSize: 6 },
            colorCycle = d3.scale.category20(),
            colorPropertyName = null,
            display = "rect",
            beginning = 0,
            ending = 0,
            margin = {left: 25, right: 30, top: 20, bottom: 20},
            stacked = false,
            rotateTicks = false,
            timeIsRelative = false,
            itemHeight = 15,
            itemMargin = 30,
            showTodayLine = false,
            showTodayFormat = {marginTop: 25, marginBottom: 20, width: 1, color: colorCycle},
            showBorderLine = false,
            showBorderFormat = {marginTop: 25, marginBottom: 20, width: 1, color: colorCycle}
            ;

        function timeline (gParent) {
            var g = gParent.append("g");
            var gParentSize = gParent[0][0].getBoundingClientRect();

            var gParentItem = d3.select(gParent[0][0]);

            var yAxisMapping = {},
                maxStack = 1,
                minTime = 0,
                maxTime = 0;

            setWidth();

            // check if the user wants relative time
            // if so, substract the first timestamp from each subsequent timestamps
//            if(timeIsRelative){
//                g.each(function (d, i) {
//                    d.forEach(function (datum, index) {
//                        datum.times.forEach(function (time, j) {
//                            if(index === 0 && j === 0){
//                                originTime = time.starting_time;               //Store the timestamp that will serve as origin
//                                time.starting_time = 0;                        //Set the origin
//                                time.ending_time = time.ending_time - originTime;     //Store the relative time (millis)
//                            }else{
//                                time.starting_time = time.starting_time - originTime;
//                                time.ending_time = time.ending_time - originTime;
//                            }
//                        });
//                    });
//                });
//            }

            // check how many stacks we're gonna need
            // do this here so that we can draw the axis before the graph
            if (stacked || (ending === 0 && beginning === 0)) {
                g.each(function (d, i) {
                    d.forEach(function (datum, index) {

                        // create y mapping for stacked graph
                        if (stacked && Object.keys(yAxisMapping).indexOf(index) == -1) {
                            yAxisMapping[index] = maxStack;
                            maxStack++;
                        }

                        // figure out beginning and ending times if they are unspecified
                        if (ending === 0 && beginning === 0){
                            datum.times.forEach(function (time, i) {
                                if (time.starting_time < minTime || (minTime === 0 && timeIsRelative === false))
                                    minTime = time.starting_time;
                                if (time.ending_time > maxTime)
                                    maxTime = time.ending_time;
                            });
                        }
                    });
                });

                if (ending === 0 && beginning === 0) {
                    beginning = minTime;
                    ending = maxTime;
                }
            }

            var scaleFactor = (1/(ending - beginning)) * (width - margin.left - margin.right);
            var darkColor = $('.backend').data('dark-color');
            var brightColor = $('.backend').data('bright-color');


            // draw the axis
            var xScale = d3.time.scale()
                .domain([beginning, ending])
                .range([margin.left + 10, width + 10  - margin.right]);

            var xAxis = d3.svg.axis()
                .scale(xScale)
                .orient(orient)
                .tickFormat(tickFormat.format)
                .ticks(tickFormat.numTicks || tickFormat.tickTime, tickFormat.tickInterval)
                .tickSize(tickFormat.tickSize);

            g.append("g")
                .attr("class", "axis")
                .attr("transform", "translate(" + 0 +","+ margin.top +")")
                .call(xAxis);

            // draw the chart
            g.each(function(d, i) {
                d.forEach( function(datum, index){

                    var data = datum.times;
                    var hasLabel = (typeof(datum.label) != "undefined");
                    var hasId = (typeof(datum.id) != "undefined");



                    if (backgroundColor) {
                        var greenbarYAxis = ((itemHeight + itemMargin) * yAxisMapping[index]);
                        g.selectAll("svg").data(data).enter()
                            .insert("rect")
                            .attr("class", "row-green-bar")
                            .attr("x", 0 + margin.left)
                            .attr("width", width - margin.right - margin.left)
                            .attr("y", greenbarYAxis)
                            .attr("height", itemHeight)
                            .attr("fill", backgroundColor)
                        ;
                    }


                    g.selectAll("svg").data(data).enter()
                        .append(display)
                        .attr("x", getXPos)
                        .attr("y", getStackPosition)
                        .attr("width", getRectWidth)
                        .attr("cy", getStackPosition)
                        .attr("cx", getXPos)
                        .attr("r", itemHeight / 2)
                        .attr("height", itemHeight)
                        .attr("filter", "url(#dropshadow)")
                        .style("fill", function(d, i){
                            if (d.color) {
                                return d.color;
                            } else if(!d.deposit) {
                                return $('.fourth_color').css('background-color');
                            } else {
                                return colorCycle(index);
                            }
                        })

                        .on("mousemove", function (d, i) {
                            hover.call(this, d, index, datum);
                        })
                        .on("mouseover", function (d, i) {
                            mouseover.call(this, d, i, datum);
                        })
                        .on("mouseout", function (d, i) {
                            mouseout.call(this, d, i, datum);
                        })
                        .on("click", function (d, i) {
                            click.call(this, d, index, datum);
                        })
//                        .attr("id", function (d, i) {
//                            if (hasId){
//                                return "timelineItem_"+datum.id;
//                            }else{
//                                return "timelineItem_"+index;
//                            }
//                        })
                        .attr("class", function (d, i) {
                            if (d.request){
                                return "requested_booking";
                            }
                        })
                        .attr("id", function(d, i) {
                            if (d.focused) {

                                return 'focused-booking';
                            }
                        })
                    ;

                    g.selectAll("svg").data(data).enter()
                        .append("text")
                        .attr("x", getXTextPos)
                        .attr("y", getStackTextPosition)
                        .attr('id', function(d) {
                            return 'label' + d.contract_id;
                        })
                        .attr('style', function(d) {
                            if(d.request || d.focused) {
                                return "fill:" + darkColor;
                            }
                            if(d.textColor) {
                                return "fill:" + d.textColor + ';'
                            } else {
                                return 'fill: ' + brightColor + ';'
                            }
                        })
                        .on("click", function (d, i) {
                            click.call(this, d, index, datum);
                        })
                        .text(function(d,i) {
                            if(getRectWidth(d,i) > 160) {
                                return d.label;
                            }
                        })
                    ;

                    var lineYAxis = ( itemHeight + 15 + itemMargin / 2 + margin.top + (itemHeight + itemMargin) * yAxisMapping[index]);
                    gParent.append("svg:line")
                        .attr("class", "row-seperator")
                        .attr("x1", 0)
                        .attr("x2", width)
                        .attr("y1", lineYAxis - 8.5)
                        .attr("y2", lineYAxis - 8.5)
                        .attr("stroke-width", 1)
                        .attr("stroke", 'slategrey');
                    ;

                    // add the label
                    gParent.append('a')
                        .attr('xlink:href', function(d) {
                           return '/rentable_items/' + datum.id;
                        })
                        .append("text")
                        .attr("class", "timeline-label")
                        .attr("transform", "translate("+ 0 +","+ (itemHeight * 1.85 + margin.top + (itemHeight + itemMargin) * yAxisMapping[index])+")")
                        .attr('fill', 'slategrey')
                        .text(datum.label);

//                    if (typeof(datum.icon) !== "undefined") {
//                        gParent.append("image")
//                            .attr("class", "timeline-label")
//                            .attr("transform", "translate("+ 0 +","+ (margin.top + (itemHeight + itemMargin) * yAxisMapping[index])+")")
//                            .attr("xlink:href", datum.icon)
//                            .attr("width", margin.left)
//                            .attr("height", itemHeight);
//                    }

                    function getStackPosition(d, i) {
                        if (stacked) {
                            return margin.top + (itemHeight + itemMargin) * yAxisMapping[index];
                        }
                        return margin.top;
                    }
                    function getStackTextPosition(d, i) {
                        if (stacked) {
                            return margin.top + (itemHeight + itemMargin) * yAxisMapping[index] + itemHeight * 0.75;
                        }
                        return margin.top + itemHeight * 0.75;
                    }
                });
            });

            if (width > gParentSize.width) {
                var move = function() {
                    var x = Math.min(0, Math.max(gParentSize.width - width, d3.event.translate[0]));
                    zoom.translate([x, 0]);
                    g.attr("transform", "translate(" + x + ",0)");
                    scroll(x*scaleFactor, xScale);
                };

                var zoom = d3.behavior.zoom().x(xScale).on("zoom", move);

                gParent
                    .attr("class", "scrollable")
                    .call(zoom);
            }
//
//            if (rotateTicks) {
//                g.selectAll("text")
//                    .attr("transform", function(d) {
//                        return "rotate(" + rotateTicks + ")translate("
//                            + (this.getBBox().width / 2 + 10) + "," // TODO: change this 10
//                            + this.getBBox().height / 2 + ")";
//                    });
//            }

            var gSize = g[0][0].getBoundingClientRect();
            setHeight();

//            if (showBorderLine) {
//                g.each(function (d, i) {
//                    d.forEach(function (datum) {
//                        var times = datum.times;
//                        times.forEach(function (time) {
//                            appendLine(xScale(time.starting_time), showBorderFormat);
//                            appendLine(xScale(time.ending_time), showBorderFormat);
//                        });
//                    });
//                });
//            }

            var todayLine = xScale(new Date());
//            appendLine(todayLine, showTodayFormat);

            gParent.append("svg:line")
                .attr("x1", todayLine)
                .attr("y1", showTodayFormat.marginTop)
                .attr("x2", todayLine)
                .attr("y2", height - showTodayFormat.marginBottom)
                .attr('class', 'today-line');//"rgb(6,120,155)")
//                .style("stroke-width", lineFormat.width);

            function getXPos(d, i) {
                if(d.starting_time <= beginning) {
                    return margin.left + 20;
                } else {
                    return margin.left + 20 + (d.starting_time - beginning) * scaleFactor;
                }
            }

            function getXTextPos(d, i) {
                return getXPos(d,i) + 5;
            }

            function getRectWidth (d, i) {
                if(d.ending_time < beginning || d.starting_time > ending) {
                    return 0;
                } else if(d.starting_time <= beginning && d.ending_time >= ending) {
                    return (ending - beginning) * scaleFactor;
                } else if(d.starting_time <= beginning) {
                    return (d.ending_time - beginning) * scaleFactor;
                } else if(d.ending_time >= ending) {
                    return (ending - d.starting_time) * scaleFactor;
                } else {
                    return (d.ending_time - d.starting_time) * scaleFactor;
                }
            }

            function setHeight() {
                // set height based off of item height
                height = gSize.height + gSize.top - gParentSize.top + 75;
                // set bounding rectangle height
                d3.select(gParent[0][0]).attr("height", height);
            }

            function setWidth() {
                if (!width && !gParentSize.width) {
                    throw "width of the timeline is not set. As of Firefox 27, timeline().with(x) needs to be explicitly set in order to render";
                } else if (!(width && gParentSize.width)) {
                    if (!width) {
                        width = gParentItem.attr("width");
                    } else {
                        gParentItem.attr("width", width);
                    }
                }
                // if both are set, do nothing
            }

            function appendLine(lineScale, lineFormat) {
                gParent.append("svg:line")
                    .attr("x1", lineScale)
                    .attr("y1", lineFormat.marginTop)
                    .attr("x2", lineScale)
                    .attr("y2", height - lineFormat.marginBottom)
                    .style("stroke", lineFormat.color)//"rgb(6,120,155)")
                    .style("stroke-width", lineFormat.width);
            }

        }

        // SETTINGS

        timeline.margin = function (p) {
            if (!arguments.length) return margin;
            margin = p;
            return timeline;
        };

        timeline.orient = function (orientation) {
            if (!arguments.length) return orient;
            orient = orientation;
            return timeline;
        };

        timeline.itemHeight = function (h) {
            if (!arguments.length) return itemHeight;
            itemHeight = h;
            return timeline;
        };

        timeline.itemMargin = function (h) {
            if (!arguments.length) return itemMargin;
            itemMargin = h;
            return timeline;
        };

        timeline.height = function (h) {
            if (!arguments.length) return height;
            height = h;
            return timeline;
        };

        timeline.width = function (w) {
            if (!arguments.length) return width;
            width = w;
            return timeline;
        };

        timeline.display = function (displayType) {
            if (!arguments.length || (DISPLAY_TYPES.indexOf(displayType) == -1)) return display;
            display = displayType;
            return timeline;
        };

        timeline.tickFormat = function (format) {
            if (!arguments.length) return tickFormat;
            tickFormat = format;
            return timeline;
        };

        timeline.hover = function (hoverFunc) {
            if (!arguments.length) return hover;
            hover = hoverFunc;
            return timeline;
        };

        timeline.mouseover = function (mouseoverFunc) {
            if (!arguments.length) return mouseoverFunc;
            mouseover = mouseoverFunc;
            return timeline;
        };

        timeline.mouseout = function (mouseoverFunc) {
            if (!arguments.length) return mouseoverFunc;
            mouseout = mouseoverFunc;
            return timeline;
        };

        timeline.click = function (clickFunc) {
            if (!arguments.length) return click;
            click = clickFunc;
            return timeline;
        };

        timeline.scroll = function (scrollFunc) {
            if (!arguments.length) return scroll;
            scroll = scrollFunc;
            return timeline;
        };

        timeline.colors = function (colorFormat) {
            if (!arguments.length) return colorCycle;
            colorCycle = colorFormat;
            return timeline;
        };

        timeline.beginning = function (b) {
            if (!arguments.length) return beginning;
            beginning = b;
            return timeline;
        };

        timeline.ending = function (e) {
            if (!arguments.length) return ending;
            ending = e;
            return timeline;
        };

        timeline.rotateTicks = function (degrees) {
            rotateTicks = degrees;
            return timeline;
        };

        timeline.stack = function () {
            stacked = !stacked;
            return timeline;
        };

        timeline.relativeTime = function() {
            timeIsRelative = !timeIsRelative;
            return timeline;
        };

        timeline.showBorderLine = function () {
            showBorderLine = !showBorderLine;
            return timeline;
        };

        timeline.showBorderFormat = function(borderFormat) {
            if (!arguments.length) return showBorderFormat;
            showBorderFormat = borderFormat;
            return timeline;
        };

        timeline.showToday = function () {
            showTodayLine = !showTodayLine;
            return timeline;
        };

        timeline.showTodayFormat = function(todayFormat) {
            if (!arguments.length) return showTodayFormat;
            showTodayFormat = todayFormat;
            return timeline;
        };

        timeline.colorProperty = function(colorProp) {
            if (!arguments.length) return colorPropertyName;
            colorPropertyName = colorProp;
            return timeline;
        };

        timeline.rowSeperators = function (color) {
            if (!arguments.length) return rowSeperatorsColor;
            rowSeperatorsColor = color;
            return timeline;
        };

        timeline.background = function (color) {
            if (!arguments.length) return backgroundColor;
            backgroundColor = color;
            return timeline;
        };

        return timeline;
    };
})();

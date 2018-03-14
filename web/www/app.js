/* Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.
 * All rights reserved.						
 *								
 *	This source code contains the intellectual property	
 *	of its copyright holder(s), and is made available	
 *	under a license.  If you do not know the terms of	
 *	the license, please stop and do not read further.	
 */

window.onload = function() {

  //TODO Sam Habiel's extra parameter suggestion?
  //should I try to grab the initial map data when the server sends the html data, or is doing it in a separate toplevel request in window.onload an okay program flow? - can ask Sam and the internet in general
  //activate node hover when mouse is over the label and not the node?
  //storing, retrieving, and updating data associated with regions, segments, etc. like memory allocation


  //Global Vars

  var sig = new sigma({
    renderer: {
      container: document.getElementById('sigma-container'),
      //type: 'canvas', //needed for edge hovering, which isn't working
    },
    /*settings: {
      enableEdgeHovering: true, //doesn't seem to be working
      minEdgeSize: 2,
      edgeHoverSizeRatio: 2,
    },*/
  });
  sig.settings('labelThreshold', 1);

  var model = {};
  var view = {
    xScalingFactor: 1,
    yScalingFactor: 1,
  };


  //initialize dialogs so that the blocker dialog can be used in getMap()

  $(".modal-dialog").dialog({
    autoOpen: false,
    modal: true,
  });

  $("#blocker").dialog({
    dialogClass: "no-close",
  });


  //initialize the graph - does this have to be done here with a function that contains a POST request, or can the necessary data be sent without the POST request in this function?
  getMap();
  //TODO how to prevent the rest of the application from being operational until the callback in getMap finishes, and only if the success branch is hit - getMap() should be effectively synchronous
  //-one part is using a "loading" blocker while getMap and its callback are running, but that alone doesn't stop the application on failure


  document.getElementById("addNodeBtn").onclick = function(e) {
    $("#addnode-dialog").dialog("open");
  }

  document.getElementById("deleteNodeBtn").onclick = function(e) {
    $("#deletenode-dialog").dialog("open");
  }

  document.getElementById("deleteNodeCancelBtn").onclick = function(e) {
    $("#deletenode-dialog").dialog("close");
  }

  document.getElementById('changeLinkBtn').onclick = function(e) {
    $('#changelink-dialog').dialog('open');
  }

  //TODO: separate UI elements for adding name/region/segment(/file)?
  document.getElementById("addNodeConfirmBtn").onclick = function(e) {
    //fixed region string: "mammals" - when checking against existing nodes, how should it handle case sensitivity?
    //current plan 2018-01-22 - don't handle it at all on the client side, have the server check it - possible avenue of optimization is to check on client side?
    //case sensitivity is different for different node types e.g. regions is insensitive, files are not - also, it might depend based on the OS - Bhaskar says files are case-sensitive across OSes
    //need to check specifics
    let nodeType = document.getElementById("addNodeTypeBox").value; //TODO sanitize this?, and other user input - here, on the server, or both? -check if multi-sanitization is okay/doesn't alter the semantic content
    let nodeNameString = document.getElementById("addNodeNameStringInput").value; //TODO sanitize this?
    if (nodeNameString === "") {
      toastr.error("Node name string cannot be empty");
      return;
    }
    /*
    let nodes = sig.graph.nodes();
    let regionNodes = nodes.filter(node => node.id.substring(0,1) === "r");
    if (regionNodes.map(node => node.label).includes(newRegion)) {
      toastr.error("Client-side error: region " + newRegion + " already exists");
      return;
    }
    */
    //can this be avoided entirely, e.g. by having different UI dialogs and functions for adding names, regions, and segments?
    let nodeInfo = null;
    try {
      nodeInfo = getNodeInfoOfType(nodeType);
    } catch (err) {
      toastr.error("Could not get node info: " + err);
      return;
    }

    //update the model, exiting early if there is a duplicate label present - label equality handling here doesn't currently use the defined functions for region/segment label equality - TODO encapsulate case-insensitive relationship
    //this switch-like block with an exception in the no-match case is a suboptimal design - split this addNode function in three, one for each case?
    if (nodeInfo.modelField === "nams") {
      if (Object.keys(model.nams).includes(nodeNameString)) {
        toastr.error('Name ' + nodeNameString + ' already exists');
        return;
      }
      model.nams[nodeNameString] = "";
    } else if (nodeInfo.modelField === "regs") {
      if (Object.keys(model.regs).map(r => r.toUpperCase()).includes(nodeNameString.toUpperCase())) { //TODO encapsulate
        toastr.error('Region ' + nodeNameString + ' already exists');
        return;
      }
      //TODO does property FILE_NAME in region template require special handling?
      //TODO is it possible for a template to have DYNAMIC_SEGMENT (region) or FILE_NAME (segment)? if so, does this code still work? (not optimally - the region/segment won't follow the template)
      model.regs[nodeNameString] = {};
      model.regs[nodeNameString].DYNAMIC_SEGMENT = "";
      Object.keys(model.tmpreg).map(propertyName => {
	if (propertyName !== "") {
          model.regs[nodeNameString][propertyName] = model.tmpreg[propertyName];
	}
      });
    } else if (nodeInfo.modelField === "segs") {
      if (Object.keys(model.segs).map(s => s.toUpperCase()).includes(nodeNameString.toUpperCase())) { //TODO encapsulate
        toastr.error('Segment ' + nodeNameString + ' already exists');
        return;
      }
      //is there a way to make this template error-check block unnecessary?
      if (!model.tmpacc) {
        toastr.error("Could not create segment: model.tmpacc not found");
        return;
      } else if (!Object.keys(model.tmpseg).includes(model.tmpacc)) {
        toastr.error("Could not create segment - model.tmpacc not recognized: " + model.tmpacc);
        return;
      }

      model.segs[nodeNameString] = {};
      model.segs[nodeNameString].FILE_NAME = "";
      let segmentTemplate = model.tmpseg[model.tmpacc];
      Object.keys(segmentTemplate).map(propertyName => {
	if (propertyName !== "") { //property with name "" seems to contain value "DEFAULT" for both BG and MM - what is its purpose?
          model.segs[nodeNameString][propertyName] = segmentTemplate[propertyName];
	}
      });
    } else throw "nodeInfo.modelField not recognized: " + nodeInfo.modelField;

    $("#addnode-dialog").dialog("close");

    //add node to graph
    const nodes = nodeInfo.nodes;
    const len = nodes.length;
    const idMaxNumber = nodes.map(node => parseInt(node.id.substring(1), 10)).reduce((max, current) => Math.max(max, current), -1);
    //find the maximum numeric portion among node IDs (which are all non-negative), defaulting to -1 if no nodes are present
    sig.graph.addNode({
      id: nodeInfo.prefix + (idMaxNumber + 1), //"[n/r/s/f]"+len will result in non-unique id error if deleting nodes doesn't adjust remaining ids such that the number portion is never >= the number of nodes
      label: nodeNameString,
      x: nodeInfo.x * view.xScalingFactor,
      y: ((nodeInfo.modelField === "nams") ? len : len * view.yScalingFactor), //will result in position overlap error if deleting nodes doesn't adjust y-position of existing nodes to make them compact
      size: 1,
      color: nodeInfo.color,
    });
    sig.refresh();
  }

  document.getElementById("deleteNodeConfirmBtn").onclick = function(e) {
    const nodeToDeleteId = $("#clicknode-dialog").data("node-id");
    const nodeToDeleteLabel = $("#clicknode-dialog").data("node-label");
    //update model
    //this way of determining node type is fragile - should try to correct it when possible
    const nodeIdPrefix = nodeToDeleteId.substring(0, 1);
    if (nodeIdPrefix === 'n') {
      delete model.nams[nodeToDeleteLabel];
    } else if (nodeIdPrefix === 'r') {
      delete model.regs[nodeToDeleteLabel];
      Object.keys(model.nams).map(nam => {
        if (regionLabelEqual(model.nams[nam], nodeToDeleteLabel)) {
          model.nams[nam] = "";
        }
      });
    } else if (nodeIdPrefix === 's') {
      delete model.segs[nodeToDeleteLabel];
      Object.keys(model.regs).map(reg => {
        if (segmentLabelEqual(model.regs[reg].DYNAMIC_SEGMENT, nodeToDeleteLabel)) {
          model.regs[reg].DYNAMIC_SEGMENT = "";
        }
      });
    } else {
      toastr.error("Unrecognized node ID prefix: " + nodeIdPrefix);
      return;
    }

    $("#deletenode-dialog").dialog("close");
    $("#clicknode-dialog").dialog("close");

    //delete node from graph
    //is it indeed safe to get the node ID by attaching it to and then grabbing it from the node info dialog? I believe it is
    sig.graph.dropNode(nodeToDeleteId);
    nodesOfType = sig.graph.nodes().filter(node => node.id.substring(0, 1) === nodeIdPrefix);
    for (let i = 0; i < nodesOfType.length; ++i) {
      nodesOfType[i].y = ((nodeIdPrefix === 'n') ? i : i * view.yScalingFactor);
    }
    /*sig.graph.addNode({
      id: "r"+len, //will result in non-unique id error if deleting nodes doesn't adjust remaining ids such that the number portion is never >= the number of nodes - update - changing node IDs without changing edge IDs is a bad idea with current design
      label: newRegion,
      x: 1,
      y: len, //will result in position overlap error if deleting nodes doesn't adjust y-position of existing nodes to make them compact
      size: 1,
      color: '#00f',
    });*/
    sig.refresh();
  }

  document.getElementById("changeLinkConfirmBtn").onclick = function(e) {
    //two cases for name-region and region-segment - linked node exists, or linked node doesn't yet exist - the latter requires refactoring the current add-node code (2018-01-30)
    //for now - only connect to existing nodes (segment-file does not have this limitation)
    const linkTargetLabel = document.getElementById("changeLinkInput").value; //TODO sanitize this? not sure if necessary
    const thisNodeId = $("#clicknode-dialog").data("node-id"); //I believe this way of grabbing the current/source node is safe
    const thisNodeLabel = $("#clicknode-dialog").data("node-label");
    //update model
    //this method of determining node type is fragile
    const thisNodeIdPrefix = thisNodeId.substring(0, 1);
    if (thisNodeIdPrefix === 'n') {
      if (linkTargetLabel !== "" && !Object.keys(model.regs).map(r => r.toUpperCase()).includes(linkTargetLabel.toUpperCase())) { //TODO encapsulate case-insensitive relationship
        toastr.error("Region " + linkTargetLabel + " does not exist");
        return;
      }
      if (regionLabelEqual(model.nams[thisNodeLabel], linkTargetLabel)) {
        $("#changelink-dialog").dialog('close');
        return;
      }
      model.nams[thisNodeLabel] = linkTargetLabel;
    } else if (thisNodeIdPrefix === 'r') {
      if (linkTargetLabel !== "" && !Object.keys(model.segs).map(s => s.toUpperCase()).includes(linkTargetLabel.toUpperCase())) { //TODO encapsulate case-insensitive relationship
        toastr.error("Segment " + linkTargetLabel + " does not exist");
        return;
      }
      if (segmentLabelEqual(model.regs[thisNodeLabel].DYNAMIC_SEGMENT, linkTargetLabel)) {
        $("#changelink-dialog").dialog('close');
        return;
      }
      model.regs[thisNodeLabel].DYNAMIC_SEGMENT = linkTargetLabel;
    } else if (thisNodeIdPrefix === 's') {
      if (model.segs[thisNodeLabel].FILE_NAME === linkTargetLabel) {
        $("#changelink-dialog").dialog('close');
        return;
      }
      model.segs[thisNodeLabel].FILE_NAME = linkTargetLabel;
    } else {
      toastr.error("Unrecognized node ID prefix: " + thisNodeIdPrefix);
      return;
    }

    $("#changelink-dialog").dialog('close');

    //update view
    const outEdgeWrapped = sig.graph.edges().filter(edge => edge.source === thisNodeId);
    if (thisNodeIdPrefix === 'n') {
      //erase existing outgoing edge, if present
      outEdgeWrapped.map(edge => sig.graph.dropEdge(edge.id));
      //draw edge, if needed
      if (linkTargetLabel !== "") {
        targetNodeId = sig.graph.nodes().filter(node => node.id.substring(0, 1) === 'r' && regionLabelEqual(node.label, linkTargetLabel))[0].id
        sig.graph.addEdge({
          id: thisNodeId + '-' + targetNodeId,
          source: thisNodeId,
          target: targetNodeId,
        });
      }
    } else if (thisNodeIdPrefix === 'r') {
      //erase existing outgoing edge, if present
      outEdgeWrapped.map(edge => sig.graph.dropEdge(edge.id));
      //draw edge, if needed
      if (linkTargetLabel !== "") {
        targetNodeId = sig.graph.nodes().filter(node => node.id.substring(0, 1) === 's' && segmentLabelEqual(node.label, linkTargetLabel))[0].id
        sig.graph.addEdge({
          id: thisNodeId + '-' + targetNodeId,
          source: thisNodeId,
          target: targetNodeId,
        });
      }
    }
    //specific to segment-file link - if a file node has no edges, it should be dropped; if a file doesn't yet have a node, it should be created
    else if (thisNodeIdPrefix === 's') {
      if (outEdgeWrapped.length > 0) { //there is an existing edge to a file node - check that file node to see if it should be erased along w/ the edge
        const oldFileNodeId = outEdgeWrapped[0].target
        outEdgeWrapped.map(edge => sig.graph.dropEdge(edge.id));
        if (sig.graph.edges().filter(edge => edge.target === oldFileNodeId).length === 0)
          sig.graph.dropNode(oldFileNodeId);
      }
      //create file node if necessary and draw edge
      if (linkTargetLabel != "") {
        const targetNodeWrapped = sig.graph.nodes().filter(node => node.id.substring(0, 1) === 'f' && node.label === linkTargetLabel)
        if (targetNodeWrapped.length > 0) {
          targetNodeId = targetNodeWrapped[0].id;
          sig.graph.addEdge({
            id: thisNodeId + '-' + targetNodeId,
            source: thisNodeId,
            target: targetNodeId,
          });
        } else {
          const fileNodes = sig.graph.nodes().filter(node => node.id.substring(0, 1) === 'f');
          const fileMaxIdNumber = fileNodes.map(node => parseInt(node.id.substring(1), 10)).reduce((max, current) => Math.max(max, current), -1);
          const targetNodeId = 'f' + (fileMaxIdNumber + 1);
          sig.graph.addNode({
            id: targetNodeId,
            label: linkTargetLabel,
            x: 3, //should centralize this, along with size and color
            y: fileNodes.length,
            size: 1,
            color: '#000',
          });
          sig.graph.addEdge({
            id: thisNodeId + '-' + targetNodeId,
            source: thisNodeId,
            target: targetNodeId,
          });
        }
      }
    }
    sig.refresh();
  }

  //can GET get local variables from M? or can POST only do so
  //make this synchronous? sync seems to be deprecated(?), and generally bad practice - currently using blocker dialog to lock out user interaction
  //this function expects a non-interim global directory state, i.e. no unconnected name/region/segment/file nodes 
  function getMap() {
    $('#blocker').dialog('open');
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.open("GET", "getmap", true);
    xmlHttp.onreadystatechange = function() {
      if (this.readyState == 4 && xmlHttp.status == 200) {
        //todo: JSON.parse error handling
        const responseObj = JSON.parse(xmlHttp.responseText);
        if (false) { //check that nams, regs, segs, and other vars were obtained
          //handle error
          $('#blocker').dialog('close');
          return; //is this the best control flow for error handling? how to deal with a now-obsolete graph already on screen? clean it up
        }
        const nams = responseObj.nams;
        const regs = responseObj.regs;
        const segs = responseObj.segs;
        delete nams[""]; //these empty string subscripts contain the number of nams/regs/segs
        delete regs[""];
        delete segs[""];
        model.nams = nams;
        model.regs = regs;
        model.segs = segs;
        model.tmpacc = responseObj.tmpacc;
        model.tmpreg = responseObj.tmpreg;
        model.tmpseg = responseObj.tmpseg;
        model.minreg = responseObj.minreg;
        model.maxreg = responseObj.maxreg;
        model.minseg = responseObj.minseg;
        model.maxseg = responseObj.maxseg;
	model.gnams = responseObj.gnams;
	model.create = responseObj.create;
	model.file = responseObj.file;
	model.useio = responseObj.useio;
	model.debug = responseObj.debug;

        //const namesArray = Object.keys(nams); //TODO: true immutability?
	/*const namesArray = Object.values(
		             Object.keys(nams).reduce((rv, nam) => {(rv[nams[nam]] = rv[nams[nam]] || []).push(nam); return rv;}, {}) //group names by region
                           ).reduce((xs, ys) => xs.concat(ys), []); //group-by returns map of regions to arrays of names; concatenate the arrays */
        let namesArray = [];
        const namesGroupedByRegion = Object.keys(nams).reduce(
	  (rv, nam) => {
	    (rv[nams[nam]] = rv[nams[nam]] || []).push(nam);
	    return rv;
	  }, {}
	);
        Object.keys(namesGroupedByRegion).sort().forEach(region => namesArray = namesArray.concat(namesGroupedByRegion[region]));
	  //populate namesArray by region alphabetical order, and in name alphabetical order within each region
        const regionsArray = Object.keys(regs);
        const segmentsArray = Object.keys(segs);
        //TODO: make sure that region/segment parameter names indeed show up on the JS side in uppercase
        //is the filter undefined operation here redundant? (i.e. if undefined segment-file associations are being treated as an error and handled elsewhere, like in the edge-drawing code in this function)
        const filesArray = Array.from(new Set(segmentsArray.map(seg => segs[seg].FILE_NAME))).filter(file => file != undefined) //Array.from(new Set(Object.values(segFileMap)));
        view.xScalingFactor = Math.max(1, namesArray.length / 3)
        view.yScalingFactor = Math.max(1, namesArray.length / regionsArray.length);
        const nameIds = {}; //cannot use name/region/etc. strings as sigma element ids due to possible duplicates
        const regionIds = {};
        const segmentIds = {};
        const fileIds = {};
        for (let i = 0; i < namesArray.length; ++i) {
          let nameId = "n" + i;
          nameIds[namesArray[i]] = nameId;
          sig.graph.addNode({
            id: nameId,
            label: namesArray[i],
            x: 0 * view.xScalingFactor,
            y: i,
            size: 1,
            color: '#f00',
          });
        }
        for (let i = 0; i < regionsArray.length; ++i) {
          let regionId = "r" + i;
          regionIds[regionsArray[i]] = regionId;
          sig.graph.addNode({
            id: regionId,
            label: regionsArray[i],
            x: 2 * view.xScalingFactor,
            y: i * view.yScalingFactor,
            size: 1,
            color: '#00f',
          });
        }
        for (let i = 0; i < segmentsArray.length; ++i) {
          let segmentId = "s" + i;
          segmentIds[segmentsArray[i]] = segmentId;
          sig.graph.addNode({
            id: segmentId,
            label: segmentsArray[i],
            x: 3 * view.xScalingFactor,
            y: i * view.yScalingFactor,
            size: 1,
            color: '#0f0',
          });
        }
        for (let i = 0; i < filesArray.length; ++i) {
          let fileId = "f" + i;
          fileIds[filesArray[i]] = fileId;
          sig.graph.addNode({
            id: fileId,
            label: filesArray[i],
            x: 4 * view.xScalingFactor,
            y: i * view.yScalingFactor,
            size: 1,
            color: '#000',
          });
        }
        namesArray.map(nam => {
          let nameId = nameIds[nam];
          //error/exception handling if for some reason the name-region mapping contains a nonexistent region
          let regionId = regionIds[nams[nam]];
          if (regionId === undefined) throw "Nonexistent region " + nams[nam] + " for name " + nam;
          sig.graph.addEdge({
            id: nameId + '-' + regionId,
            source: nameId,
            target: regionId,
          });
        });
        regionsArray.map(reg => {
          let regionId = regionIds[reg];
          //error/exception handling if for some reason the region-segment mapping contains a nonexistent segment or if the segment is missing
          let seg = regs[reg].DYNAMIC_SEGMENT;
          if (seg === undefined) throw "Missing segment for region " + reg;
          let segmentId = segmentIds[seg];
          if (segmentId === undefined) throw "Nonexistent segment " + seg + " for region " + reg;
          sig.graph.addEdge({
            id: regionId + '-' + segmentId,
            source: regionId,
            target: segmentId,
          });
        });
        segmentsArray.map(seg => {
          let segmentId = segmentIds[seg];
          //error/exception handling if for some region a segment is missing an associated file (There won't be a nonexistent file here since the file list is obtained by grabbing all segment FILE_NAME values)
          let file = segs[seg].FILE_NAME;
          if (file === undefined) throw "Missing file for segment " + seg;
          let fileId = fileIds[file];
          sig.graph.addEdge({
            id: segmentId + '-' + fileId,
            source: segmentId,
            target: fileId,
          });
        });
        /* old version of the code where things were in simple name-region, region-segment, and segment-file maps
        for (let name in namRegMap) {
          if (namRegMap.hasOwnProperty(name)) {
            let nameId = nameIds[name];
            //todo: error/exception handling if for some reason the name-region map has a region value that is not in the region-segment map keys
            let regionId = regionIds[namRegMap[name]];
            sig.graph.addEdge({
              id: nameId+'-'+regionId,
              source: nameId,
              target: regionId,
            });
          }
        }
        for (let region in regSegMap) {
          if (regSegMap.hasOwnProperty(region)) {
            let regionId = regionIds[region];
            //todo: error/exception handling if for some reason the region-segment map has a segment value that is not in the segment-file map keys
            let segmentId = segmentIds[regSegMap[region]];
            sig.graph.addEdge({
              id: regionId+'-'+segmentId,
              source: regionId,
              target: segmentId,
            });
          }
        }
        for (let segment in segFileMap) {
          if (segFileMap.hasOwnProperty(segment)) {
            let segmentId = segmentIds[segment];
            let fileId = fileIds[segFileMap[segment]];
            sig.graph.addEdge({
              id: segmentId+'-'+fileId,
              source: segmentId,
              target: fileId,
            });
          }
        }
        */
        sig.refresh();
      } else if (this.readyState == 4 && xmlHttp.status != 200) {
        toastr.error("unsuccessful: Http status " + xmlHttp.status);
      }
      $('#blocker').dialog('close');
    }
    xmlHttp.setRequestHeader("Content-Type", "text/plain");
    xmlHttp.send('placeholder payload'); //can there be no string?
  }

  //don't think this needs forced synchrony - just Save function
  //TODO print proper error message to screen; speed up latency? (server side, I think)
  document.getElementById('verifyBtn').onclick = function(e) {
    var sendObj = {};
    sendObj.nams = model.nams;
    sendObj.regs = model.regs;
    sendObj.segs = model.segs;
    sendObj.tmpreg = model.tmpreg;
    sendObj.tmpseg = model.tmpseg;
    sendObj.tmpacc = model.tmpacc;
    sendObj.gnams = model.gnams;
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.open("POST", "verify", true);
    xmlHttp.onreadystatechange = function() {
      if (this.readyState == 4 && xmlHttp.status == 201) {
        //2012-02-28 AKB - response text is XML with one line containing a JSON object instead of pure JSON, for some reason
        //const responseObj = JSON.parse(xmlHttp.responseText);
        const responseArr = xmlHttp.responseText.split('\n');
        let responseObj = null;
        console.log(responseArr);
        for (let i = 0; i < responseArr.length; ++i) {
           try {
             responseObj = JSON.parse(responseArr[i]);
             break;
           } catch(error) {
             console.log(error);
             continue;
           }
        }
        console.log(responseObj);
        if (false) {
          //parse/missing-data error handling block - to fill in
          return;
        }
        if (responseObj.verifyStatus == 'success') {
          toastr.success("Verification successful");
        } else {
          toastr.error("Verification unsuccessful");
        }
      } else if (this.readyState == 4 && xmlHttp.status != 200) {
        toastr.error("Verify encountered server error: Http status " + xmlHttp.status);
      }
    }
    xmlHttp.setRequestHeader("Content-Type", "application/json");
    xmlHttp.send(JSON.stringify(sendObj));
  }

  //needs forced synchrony
  document.getElementById('saveBtn').onclick = function(e) {
    $('#blocker').dialog('open');
    var sendObj = {};
    sendObj.nams = model.nams;
    sendObj.regs = model.regs;
    sendObj.segs = model.segs;
    sendObj.tmpreg = model.tmpreg;
    sendObj.tmpseg = model.tmpseg;
    sendObj.tmpacc = model.tmpacc;
    sendObj.gnams = model.gnams;
    sendObj.create = model.create;
    sendObj.file = model.file;
    sendObj.useio = model.useio;
    sendObj.debug = model.debug;
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.open("POST", "save", true);
    xmlHttp.onreadystatechange = function() {
      if (this.readyState == 4 && xmlHttp.status == 200) {
        const responseObj = JSON.parse(xmlHttp.responseText);
        if (false) {
          //parse/missing-data error handling block - to fill in
          $('#blocker').dialog('close');
          return;
        }
        console.log(responseObj);
	//TODO update the graph
      } else if (this.readyState == 4 && xmlHttp.status != 200) {
        toastr.error("Save encountered server error: Http status " + xmlHttp.status);
      }
      $('#blocker').dialog('close');
    }
    xmlHttp.setRequestHeader("Content-Type", "application/json");
    xmlHttp.send(JSON.stringify(sendObj));
  }

  sig.bind('clickNode', function(e) {
    const nodeIdPrefix = e.data.node.id.substring(0, 1); //this method of determining node type is fragile - change when possible
    if (nodeIdPrefix === 'f') return;
    $("#clicknode-dialog").data("node-id", e.data.node.id);
    $("#clicknode-dialog").data("node-label", e.data.node.label);
    $("#clicknode-dialog p").text(e.data.node.label);
    if (nodeIdPrefix === 'n') {
      $("#changeLinkBtn").text("Change Region");
      //document.getElementById("changelink-dialog").title = "Change Region";
      $("#changelink-dialog").dialog({
        title: "Change Region"
      });
    } else if (nodeIdPrefix === 'r') {
      $("#changeLinkBtn").text("Change Segment");
      //document.getElementById("changelink-dialog").title = "Change Segment";
      $("#changelink-dialog").dialog({
        title: "Change Segment"
      });
    } else if (nodeIdPrefix === 's') {
      $("#changeLinkBtn").text("Change File");
      //document.getElementById("changelink-dialog").title = "Change File";
      $("#changelink-dialog").dialog({
        title: "Change File"
      });
    } else return; //this is an error case in the current design - node is not name, region, segment, or file - how to signal to the developers/users?
    $("#clicknode-dialog").dialog("open");
    /*$.contextMenu({
       selector: '#sigma-container',
       trigger: 'left',
       build: function($trigger, e2) {
         return {
           callback: function(){},
           items: {
             menuItem: {name: "My item"}
           }
         };
       }
    });*/
    /*$.contextMenu({
      selector: '#sigma-container', 
      trigger: 'left',
      callback: function(key, options) {
        var m = "clicked: " + key;
        window.console && console.log(m) || alert(m); 
        console.log("End of context menu callback");
      },
      items: {
        "delete": {name: "Delete"},
      }
    });*/
    //window.prompt("Text here");
  });

  function getNodeInfoOfType(type) {
    let nodeInfo = {};
    //should refactor such that getMap and this function look up prefix/x/color info from the same place, rather than repeating it in multiple places
    if (type === "name") {
      nodeInfo.modelField = "nams";
      nodeInfo.prefix = "n";
      nodeInfo.x = 0;
      nodeInfo.color = '#f00';
    } else if (type === "region") {
      nodeInfo.modelField = "regs";
      nodeInfo.prefix = "r";
      nodeInfo.x = 1;
      nodeInfo.color = '#00f';
    } else if (type === "segment") {
      nodeInfo.modelField = "segs";
      nodeInfo.prefix = "s";
      nodeInfo.x = 2;
      nodeInfo.color = '#0f0';
    }
    /*else if (type === "file") {
      nodeInfo.prefix = "f";
      nodeInfo.x = 3;
      nodeInfo.color = '#000';
    }*/
    else {
      throw "Node type not valid: " + type;
    }
    nodeInfo.nodes = sig.graph.nodes().filter(node => node.id.substring(0, 1) === nodeInfo.prefix);
    return nodeInfo;
  }

  function regionLabelEqual(r1, r2) {
    return r1.toUpperCase() === r2.toUpperCase();
  }

  function segmentLabelEqual(s1, s2) {
    return s1.toUpperCase() === s2.toUpperCase();
  }

  //context menu
  /*  $.contextMenu({
        selector: '#sigma-container', 
        trigger: 'left',
        callback: function(key, options) {
            var m = "clicked: " + key;
            window.console && console.log(m) || alert(m); 
            console.log("End of context menu callback");
        },
        items: {
            "delete": {name: "Delete"},
        }
    });

    $.contextMenu({
        selector: '#sigma-container', 
        build: function($trigger, e) {
            console.log(e);
            // this callback is executed every time the menu is to be shown
            // its results are destroyed every time the menu is hidden
            // e is the original contextmenu event, containing e.pageX and e.pageY (amongst other data)
            return {
                trigger: 'left',
                callback: function(key, options) {
                    var m = "clicked: " + key;
                    window.console && console.log(m) || alert(m); 
                },
                items: {
                    "edit": {name: "Edit", icon: "edit"},
                    "cut": {name: "Cut", icon: "cut"},
                    "copy": {name: "Copy", icon: "copy"},
                    "paste": {name: "Paste", icon: "paste"},
                    "delete": {name: "Delete", icon: "delete"},
                    "sep1": "---------",
                    "quit": {name: "Quit", icon: function($element, key, item){ return 'context-menu-icon context-menu-icon-quit'; }}
                }
            };
        }
    });
  */
}

/*alternate UI options:
click button outside of graph to bring up "add" prompt, with dropdown for node type and input field for text (jQuery UI?)
click node for info prompt, with "delete" button inside, and also "connect to region" for names, "connect to segment" for regions (and maybe also "connect to name")
-dropdown or text entry?
*/

//what happens if the connection terminates mid-way through editing? what will happen on reload?
//-disconnection should quit without saving on the server, I think

//don't do a round trip on every add/delete - only on verify or save
//-in that case - diffing JS state with M state and handling spanning regions?
//what is the state of GDE after successful/unsuccessful verify, save?
//-how to handle asynchrony/changes made between requesting a verify/save and getting a success/fail response from the server - force synchrony?

//M mode vs UTF-8 mode? TODO (defer until after prototype?)
//"sig.kill" on reloading graph?
//make sure on the M side to allow only one connection after startup, and only keep-alive connections

//differences between empty string and no value for GDE locals?

//the UI can enforce more requirements on add/delete than GDE does, I think - or fewer, if they get resolved during the upload step
//specify connections when creating nodes (except files)?


//other GDE locals needed: maybe defreg and defseg
//what are "BG" and "MM" in tmpseg/min&maxseg? (also defseg? check)

//how to deal with local locks (#) and catchall (*) parts of nams? DEFAULT reg & seg? TODO
//-display # as "Local Locks" or similar - what happens if the user modifies it/tries to modify it? how should it appear on the server side?
//-make un-deletable, store as "#" in model, and display label as "<LOCAL LOCKS>"? or display as "# (Local Locks)"?
//-if it is deletable, special way of having to re-create?
//-special error message for trying to create duplicate # name node, since model name doesn't match display name? something like "#, which represents local locks, already exists"
//-also make * un-deletable?

//need to separate model and view code

//DataBallet uses globals for scratch space - this can't happen in production
//simply convert DataBallet globals to locals? -changed TMP, CACHE, and SESSION (there might be more) - stopping DataBallet was abnormal - UI displayed map for original GLD, failed to display when switching to acct.gld - need to figure out why
//check out Sam's web server code

//TODO remove r/userconf.m from git repo
//
//TODO clean stop, accept only one connection, template modification (JS side), save/verify, changes to GDE - where do they get saved? (-work locally now, merge into YottaDB repo later), load and test more glds
//TODO better handling of large numbers of graph nodes
//TODO better graph organization - what algorithm? minimize total line distance? minimize sum of squares of line distances? group by names by region? re-render button for simplifying graph after adding or deleting nodes and/or re-render on add/delete?
//-region/segment/file spacing scaling factor? on draw/add/delete events for non-name nodes
//-also an x-scaling factor
//
//GETOUT^GDEEXIT when connection closes?

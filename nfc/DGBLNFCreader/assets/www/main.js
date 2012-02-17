

var ready = function() {
    function win() {
        console.log("Listening for tags with mime type " + tagMimeType);
    }

    function fail(reason) {
        navigator.notification.alert(reason, function() {}, "There was a problem");
    }

    nfc.addMimeTypeListener(tagMimeType, myNfcListener, win, fail);
    
    nfc.addNdefListener(
        
 //       function() {
//            showText("This is an NDEF tag but doesn't match the mime type ");
//            showText("This is an NDEF tag but doesn't match the mime type " + tagMimeType + ".");
//        },
        myNfcListener,
        function() {
            console.log("Listening for NDEF tags.");
        },
        fail
    );
    
    nfc.addNdefFormatableListener(
        function() {
            navigator.notification.vibrate(100);
            showText("This tag is can be NDEF formatted.    ");
        },
        function() {
            console.log("Listening for tags that can be NDEF formatted.");
        },
        fail
    );
    showInstructions();
};

/*global Ndef */
var tagMimeType = "DGBL/mimetype";

function template(record) {
    var recordType = nfc.bytesToString(record.type),
    payload;

    if (recordType === "T") {
        var langCodeLength = record.payload[0],
        text = record.payload.slice((1 + langCodeLength), record.payload.length);

        payload = nfc.bytesToString(text);

    } else if (recordType === "U") {
        var url =  nfc.bytesToString(record.payload);
        payload = "<a href='" + url + "'>" + url + "<\/a>";

    } else {
        payload = nfc.bytesToString(record.payload);

    }
//	mp3file = new Media("/android_asset/test.mp3",
  //      function() {
    //        alert("playAudio():Audio Success");
      //  },
        //    function(err) {
          //      alert(err);
        //}
       // );
      //mp3file.play();
      
       
  window.plugins.videoPlayer.play("file:///sdcard/demo1-small.mp4");

 //   return ("record type: <b>" + recordType + "<\/b>" + "<br/>" + payload);
   return ("text read:" + payload);
}

        function onSuccess() {
            console.log("playAudio():Audio Success");
        }

        // onError Callback 
        //
        function onError(error) {
            alert('code: '    + error.code    + '\n' + 
                  'message: ' + error.message + '\n');
        }



function showProperty(parent, name, value) {
    var dt, dd;
    dt = document.createElement("dt");
    dt.innerHTML = name;
    dd = document.createElement("dd");
    dd.innerHTML = value;
    parent.appendChild(dt);
    parent.appendChild(dd);
}

function clearScreen() {
    document.getElementById("tagContents").innerHTML = "";
}

function showText(text) {
    document.getElementById("tagContents").innerHTML = text;    
}

function showInstructions() {
    document.getElementById("tagContents").innerHTML =
    "<div id='instructions'>" +
    " <p>Scan a tag to begin.<\/p>" +
    " <p>Expecting Mime Media Tags with a type of " + tagMimeType + ".<\/p>" +
    "<\/div>";
}

function myNfcListener(nfcEvent) {
    console.log(JSON.stringify(nfcEvent.tag));
    clearScreen();

    var tag = nfcEvent.tag;    
    var records = tag.ndefMessage || [],
    display = document.getElementById("tagContents");
    display.appendChild(
        document.createTextNode(
            "Scanned a NDEF tag with " + records.length + " record" + ((records.length === 1) ? "": "s")
        )
    );
    
    var meta = document.createElement('dl');
    display.appendChild(meta);
    showProperty(meta, "Type", tag.type);
    showProperty(meta, "Max Size", tag.maxSize + " bytes");
    showProperty(meta, "Is Writable", tag.isWritable);
    showProperty(meta, "Can Make Read Only", tag.canMakeReadOnly);
    
 
    for (var i = 0; i < records.length; i++) {
        var record = records[i],
        p = document.createElement('h1');
        p.innerHTML = template(record);
        display.appendChild(p);
    }
    navigator.notification.vibrate(0);
    var selecturl = "http://169.14.55.28/video/select.aspx?file=demo1.mp4";      
   xmlHttp = new XMLHttpRequest();     
   xmlHttp.open( "GET", selecturl, true );     
   xmlHttp.send( null ); 
    
}

var preventBehavior = function(e) {
    e.preventDefault();
};


function init() {
    // the next line makes it impossible to see Contacts on the HTC Evo since it
    // doesn't have a scroll button
    // document.addEventListener("touchmove", preventBehavior, false);
//    document.addEventListener("deviceready", deviceInfo, true);
    document.addEventListener("deviceready", ready, true);
}

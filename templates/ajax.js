function DataRequestor()
{
    var self = this;
    var post = 'POST';
    var get = 'GET';

    this.getXmlHttp = function() {
        if( document.all )
        {
            self.xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");        
        }
        else
        {
            self.xmlHttp = new XMLHttpRequest();    
        }

        return self.xmlHttp;
    }


    this.getURL = function(url) {
            self.getXmlHttp();
            self.xmlHttp.onreadystatechange = self.callback;

            // Set the default request type
            var requestType = get;

            // Generate the GET string            
            var getUrlString = "";
            if( self.args[get].length > 0 )
            {
                getUrlString = '?' + self.args[get].join('&');
            }
            
            // Generate the POST string
            var postUrlString = "";
            if( self.args[post].length > 0 )
            {
                postUrlString = self.args[post].join('&');
            }

            // Only POST if we have post variables
            if( postUrlString != "" )
            {
                requestType = post;  
            }
        
            // Make the request
            self.xmlHttp.open(requestType, url + getUrlString, true);
            self.xmlHttp.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
            self.xmlHttp.send(postUrlString);

       return true;
    }


    // Default callback method
    this.callback = function() {
        
        // Good response
        if(self.xmlHttp.readyState == 4 && self.xmlHttp.status == 200)
        {            
            if(self.onload)
            {
                self.onload(self.xmlHttp.responseText);
            }
        }

        // Bad response
        else if(self.xmlHttp.readyState == 4)
        {
            if(self.onfail)
            {
                self.onfail(self.xmlHttp.status);
            } 
            else
            {
                throw new Error("Data Request failed with an HTTP status of " + self.xmlHttp.status);
            }
        }
    }


    // Add a POST or GET argument
    this.addArg = function(type, name, value) {
        self.args[type].push(name + '=' + escape(value));
    }


    // Reset everything to defaults
    this.clear = function() {
        self.args = new Array();
        self.onload = null;
        self.onfail = null;
        self.onprogress = null;
        self.args[post] = new Array();
        self.args[get] = new Array();
    }


    // Clear out and prepare for use
    this.clear();
}

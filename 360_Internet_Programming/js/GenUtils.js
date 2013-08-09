
//---------------- Dealing with Testing ----------------------

 
//	writes assertion result on the page
function assertToPage(value, description){
	var li = document.createElement("li");
	li.className = value ? "pass" : "fail";
	li.appendChild(document.createTextNode(description));
	document.getElementById("results").appendChild(li);
};

// writes assertion to console
function assert(value, desc){
	Console.log("Result " + value + desc);
}


//--------------- DOM Manipulation --------------------------

//	sets the style of an element
function setStyle(obj, styleStr){
	obj.setAttribute('style',styleStr);
	obj.style.cssText = styleStr;
};


//--------------- Dealing with Numbers ---------------------- 


//	returns if the string contains only numeric characters
function isInteger(str){
	return (/^-?\d$/.test(str));
};

//	returns if the string is only a positve integer
function isPositiveInt(str){
	return (/^\d+$/.test(str));
};

//	returns the smallest element in an array
function smallest(array){
	return Math.min.apply(Math,array);
};


//	returns the largest element in an array
function largest(array){
	return Math.max.apply(Math,array);
};


// returns if a number is prime or not
function isPrime(value){
	if(!isPrime.answers)
		isPrime.answers = {};
	if(isPrime.answers[value] != null)
		return isPrime.answers[value];

	var prime = value != 1; //1 can never be prime
	for(var i = 2; i < value; i++){
		if(value % i == 0){
			prime = false;
			break;
		}
	}

	return isPrime.answers[value] = prime;
};

//------------------ Dealing with Strings -----------------


//	removes white space to the right and left of string
function trim(str){
	return str.replace(/^\s+|\s+$/g, "");
};

// Truncates a string to a given length
function truncate(str, len){
	if(str.length > len)
		str = str.substring(0,len);
	return str;
};

//------------------ Dealing with Arrays ----------------

//Removes an item from a given array
function removeArrayItem(arr, item){
	var i = 0;
	while(i < arr.length){
		if(arr[i] == item)
			arr.splice(i,1);
		else
			i++;
	}
};

// Does a given array contain an item
function contains(arr, item){
	for(var i = 0; i < arr.length; i++){
		if(arr[i] == item)
			return true;
	}

	return false;
};

//----------------- Dealing with Type Detection --------

// Is an object a string
function isString(obj){
	return typeof(obj) == 'string';
};

// Is an object an array
function isArray(obj){
	return obj && !(obj.propertyIsEnumerable('length'))
			&& typeof obj === 'object'
			&& typeof obj.length === 'number';
};

// is an object an email address
function isEmail(obj){
	return isString(obj) && obj.match(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/ig);
}

// is an object a url
function isUrl(obj){
	if(!isString(obj))
		return false;
	var regex = new RegExp("^(http|https)\://([a-zA-Z0-9\.\-]+(\:" +
            "[a-zA-Z0-9\.&%\$\-]+)*@)*((25[0-5]|2[0-4][0-9]|" +
            "[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\.(25[0-5]|2" +
            "[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\." +
            "(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|" +
            "[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]" +
            "{1}[0-9]{1}|[0-9])|localhost|([a-zA-Z0-9\-]+\.)*[a-zA-Z" +
            "0-9\-]+\.(com|edu|gov|int|mil|net|org|biz|arpa|info|name" +
            "|pro|aero|coop|museum|[a-zA-Z]{2}))(\:[0-9]+)*(/($|[a-z" +
            "A-Z0-9\.\,\?\'\\\+&%\$#\=~_\-]+))*$");
	return obj.match(re);
}
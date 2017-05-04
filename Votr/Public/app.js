  (function(){
	  
	  // Initialize Firebase
	  const config = {
		  apiKey: "AIzaSyCDFNhQs5azFWESVVjx7rjkg2O34zuzPy0",
		  authDomain: "votr2-51a84.firebaseio.com",
		  databaseURL: "https://votr2-51a84.firebaseio.com",
		  storageBucket: "votr2-51a84.appspot.com",
	  };
	  firebase.initializeApp(config);
	  
	  // Get elements
	  const preObject = document.getElementById('object');
	  
	  // Create Reference
	  const dbRefObject = firebase.database().ref().child('topics');
	  
	  //sync object changes
	  dbRefObject.on('value', snap => {
		  preObject.innerText = JSON.stringify(snap.val(),null,3);
	  });
	  
	  dbRefObject.on('value', snap => console.log(snap.value()));
	  
  }());
  

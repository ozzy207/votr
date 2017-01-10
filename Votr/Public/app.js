  (function(){
	  
	  // Initialize Firebase
	  const config = {
		  apiKey: "AIzaSyDaUv2pueITb8Xd-2DJvx8HrSEAYJe4-Jc",
		  authDomain: "votr-b14fb.firebaseapp.com",
		  databaseURL: "https://votr-b14fb.firebaseio.com",
		  storageBucket: "votr-b14fb.appspot.com",
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
  

﻿<cfcomponent extends="coldbox.system.testing.BaseTestCase">
<cfscript>
	this.loadColdBox = false;
	
	function setup(){
		super.setup();
		
		// init with defaults
		injector = getMockBox().createMock("coldbox.system.ioc.Injector");

		// init injector
		injector.init();
		
		mockLogger = getMockBox().createStub().$("canDebug", false).$("error");
		util = getMockBox().createMock("coldbox.system.core.util.util").$("getInheritedMetaData").$results({path="path.to.object"});
		injector.$property("instance.utility","variables",util);
		injector.$property("instance.log","variables", mockLogger);
	}

	function testShutdown(){
		// mocks
		parent = getMockBox().createStub().$("shutdown");
		cachebox = getMockBox().createStub().$("shutdown");
		eventManager = getMockBox().createStub().$("processState");
		injector.setParent( parent );
		injector.$property("cachebox", "instance", cachebox)
			.$property("eventManager", "instance", eventManager)
			.$("isCacheBoxLinked", true).$("removeFromScope");
		mockLogger.$("canInfo", true).$("info");
		
		injector.shutdown();
		assertTrue( eventManager.$times(2, "processState") );
		assertTrue( parent.$once( "shutdown" ) );
		assertTrue( injector.$once( "removeFromScope" ) );
		assertTrue( cacheBox.$once( "shutdown" ) );
	}

	function testbuildBinder(){
		//1: plain CFC path
		makePublic(injector,"buildBinder");
		binder = injector.buildBinder("coldbox.tests.specs.ioc.config.samples.SampleWireBox",{});
		assertTrue( isObject(binder) );

		//2: WireBox Binder instance
		binder = getMockBox().createMock("coldbox.tests.specs.ioc.config.samples.WireBox");
		binder.$("configure");
		injector.buildBinder(binder,{});
		assertEquals(1, binder.$count("configure") );

		//3: Simple Binder CFC
		binder = getMockBox().createMock("coldbox.tests.specs.ioc.config.samples.SampleWireBox");
		system = createObject("java","java.lang.System");
		id = system.identityHashCode(binder);
		binder2 = injector.buildBinder(binder,{});
		assertFalse( system.identityHashCode(binder2) eq id);
	}

	function testGetBinder(){
		debug( injector.getBinder() );
		assert( isObject( injector.getBinder() ) );
	}
	function testgetVersion(){
		debug( injector.getVersion() );
		assert( len( injector.getVersion() ) );
	}
	function testGetInjectorID(){
		debug( injector.getInjectorID() );
		assertEquals( createObject('java','java.lang.System').identityHashCode(injector), injector.getInjectorID() );
	}

	function testRegisterListeners(){
		makePublic(injector, "registerListeners");

		//Mocking
		listeners = [
			{class="coldbox.tests.specs.ioc.config.listeners.MyListener",
			 name="myDude", properties={}},
			{class="coldbox.tests.specs.ioc.config.listeners.MyListener",
			 name="lui", properties={}}
		];
		binder = injector.getBinder();
		getMockBox().prepareMock( binder ).$("getListeners", listeners);
		getMockBox().prepareMock( injector.getEventManager() ).$("register");

		injector.registerListeners();

		assertEquals( 2, injector.getEventManager().$count("register") );

		// exception
		listeners = [
			{class="coldbox.tests.specs.ioc.config.listeners.MyLister",
			 name="myDude", properties={}}
		];
		getMockBox().prepareMock( binder ).$("getListeners", listeners);
		try{
			injector.registerListeners();
		}
		catch("Injector.ListenerCreationException" e){}
		catch(Any e){ fail(e); }

	}

	function testdoScopeRegistration(){
		makePublic(injector, "doScopeRegistration");
		scopeReg = {key = "wirebox",scope="application"};

		binder = injector.getBinder();
		getMockBox().prepareMock( binder ).$("getScopeRegistration", scopeReg);
		injector.doScopeRegistration();
		structKeyExists( application, "wirebox" ); 
		structDelete( application, "wirebox");
	}

	function testConfigureCacheBox(){
		makePublic(injector,"configureCacheBox");
		config = {
			enabled = true,
			configFile = "",
			classNamespace = "coldbox.system.cache"
		};

		assertFalse( injector.isCacheBoxLinked() );

		//1 mock instance
		config.cacheFactory = getMockBox().createStub();
		injector.configureCacheBox( config );
		assertEquals( config.cacheFactory, injector.getCacheBox() );

		//2: enabled, no config, default config
		config.cacheFactory = "";
		injector.configureCacheBox( config );
		assertEquals( true, injector.getCacheBox().cacheExists('default') );

		// 3: with config
		config.configFile = "coldbox.system.web.config.CacheBox";
		injector.configureCacheBox( config );
		assertEquals( true, injector.getCacheBox().cacheExists('template') );

		assertTrue( injector.isCacheBoxLinked() );
	}

	function testConfigureLogBox(){
		makePublic(injector,"configureLogBox");
		injector.configureLogBox("coldbox.system.ioc.config.LogBox");

		assertTrue( isObject(injector.getLogBox()) );
	}

	function testConfigureEventManager(){
		makePublic(injector,"configureEventManager");
		injector.configureEventManager();

		assertTrue( isObject(injector.getEventManager()) );
	}

	function testGetScopeRegistration(){
		reg = injector.getScopeRegistration();
		assertFalse( structIsEmpty(reg) );
	}

	function testColdBox(){

		assertFalse( injector.isColdBoxLinked() );
		injector.$property("coldbox","instance", getMockBox().createStub() );
		assertTrue( injector.isColdBoxLinked() );
	}

	function testGetObjectPopulator(){
		pop = injector.getObjectPopulator();
		assertTrue( isInstanceOf(pop,"coldbox.system.core.dynamic.BeanPopulator") );
	}

	function testParenInjector(){
		assertTrue( isSimpleValue(injector.getParent() ));
		assertFalse( isObject(injector.getParent() ) );

		injector.setParent( injector );
		assertTrue( isObject(injector.getParent() ));
	}

	function testRemoveFromScope(){
		scopeReg = {enabled= true, key = "wirebox",scope="application"};
		binder = injector.getBinder();
		getMockBox().prepareMock( binder ).$("getScopeRegistration", scopeReg);
		application.wirebox = getMockBox().createStub();

		injector.removeFromScope();
		assertFalse( structKeyExists( application, "wirebox") );
	}

	function testAutowireCallsGetInheritedMetaDataForTargetID(){
	injector.autowire( target=getMockBox().createStub() );
	assertTrue( util.$once("getInheritedMetaData") );
	}

	function testAutowireCallsGetInheritedMetaDataForMD(){
	injector.autowire( target=getMockBox().createStub() , targetID = "myTargetID");
	assertTrue( util.$once("getInheritedMetaData") );
	}



</cfscript>
</cfcomponent>
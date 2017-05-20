component extends="coldbox.system.testing.BaseModelTest" model="coldbox.system.core.dynamic.BeanPopulator" {

	public function setup() {
		super.setup();
		populator = model.init();
	}


	public void function testGetRelationshipMetaData() output=false {
		var obj = entityNew("User");
		makePublic( populator,"getRelationshipMetaData");
		var meta = populator.getRelationshipMetaData( target = obj );

		assertTrue( isStruct( meta ) );
		for( var item in meta ) {
			assertTrue( structKeyExists( meta[ item ], "cfc" ) );
		}
	}


	public void function testPopulateFromStructWithComposeRelationships() output=false {
		var obj = entityNew("User");
		var role = entityNew("Role");

		var myStruct = {
			id = "",
			firstName = "Luis",
			lastName = "Majano",
			role = 1
		};

		// Populate From Struct - populate role
		var user = populator.populateFromStruct(target=obj, memento=myStruct, composeRelationships=true);
		expect( user.getRole() ).toBeComponent();

		var roleArgs = {
			Users = [ "4028818e2fb6c893012fe637c5db00a7", "88B73A03-FEFA-935D-AD8036E1B7954B76" ]
		};

		role = populator.populateFromStruct(target=role, memento=roleArgs, composeRelationships=true);
		// Have to comment out DI in User.cfc to work!!
	}


	public void function testPopulateFromStructWithEmptyNullIncludes() output=false {
		var obj = entityNew("User");

		var myStruct = {
			id = "",
			firstName = "Luis",
			lastName = "Majano",
			username = "",
			password = ""
		};

		// Populate From Struct - no columns null
		var userNoNull = populator.populateFromStruct(target=obj, memento=myStruct, nullEmptyInclude="");

		assertEquals( myStruct.firstName, userNoNull.getFirstName() );
		assertFalse( isNull( userNoNull.getUsername() ) );
		assertFalse( isNull( userNoNull.getPassword() ) );

		// Populate From Struct - One column null
		var userOneNull = populator.populateFromStruct(target=obj, memento=myStruct, nullEmptyInclude="username");

		assertEquals( myStruct.firstName, userOneNull.getFirstName() );
		assertTrue( isNull( userOneNull.getUsername() ) );
		assertFalse( isNull( userOneNull.getPassword() ) );

		// Populate From Struct - All columns null
		var userAllNull = populator.populateFromStruct(target=obj, memento=myStruct, nullEmptyInclude="*");

		assertEquals( myStruct.firstName, userAllNull.getFirstName() );
		assertTrue( isNull( userAllNull.getUsername() ) );
		assertTrue( isNull( userAllNull.getPassword() ) );
	}


	public void function testPopulateFromStructWithEmptyNullExcludes() output=false {
		var obj = entityNew("User");

		var myStruct = {
			id = "",
			firstName = "Luis",
			lastName = "Majano",
			username = "",
			password = ""
		};

		// Populate From Struct - no columns null
		var userNoNull = populator.populateFromStruct(target=obj, memento=myStruct, nullEmptyExclude="");

		assertEquals( myStruct.firstName, userNoNull.getFirstName() );
		assertFalse( isNull( userNoNull.getUsername() ) );
		assertFalse( isNull( userNoNull.getPassword() ) );

		// Populate From Struct - One column not null
		var userOneNull = populator.populateFromStruct(target=obj, memento=myStruct, nullEmptyInclude="*", nullEmptyExclude="username");

		assertEquals( myStruct.firstName, userOneNull.getFirstName() );
		assertFalse( isNull( userOneNull.getUsername() ) );
		assertTrue( isNull( userOneNull.getPassword() ) );

		// Populate From Struct - All columns null
		var userAllNull = populator.populateFromStruct(target=obj, memento=myStruct, nullEmptyExclude="*");

		assertEquals( myStruct.firstName, userAllNull.getFirstName() );
		assertFalse( isNull( userAllNull.getUsername() ) );
		assertFalse( isNull( userAllNull.getPassword() ) );
	}


	public void function testPopulateFromStructWithNulls() output=false {
		var obj = entityNew("User");

		var myStruct = {
			id = "",
			firstName = "Luis",
			lastName = "Majano",
			username = ""
		};

		// Populate From Struct
		var user = populator.populateFromStruct(target=obj, memento=myStruct, ignoreEmpty=true);

		assertEquals( myStruct.firstName, user.getFirstName() );
		assertTrue( isNull( user.getID() ) );
		assertTrue( isNull( user.getUsername() ) );
	}


	public void function testPopulateFromStruct() output=false {
		// formBean object: fname,lname,email,initDate
		var obj = getMockBox().createMock('coldbox.test-harness.models.formBean');

		var myStruct = {
			fname = "Luis",
			lname = "Majano",
			email = "test@coldboxframework.com",
			initDate = now()
		};

		obj = populator.populateFromStruct(obj, myStruct);
		var objInstance = obj.getInstance();

		// Assert Population
		for( var key in objInstance ) {
			assertEquals( objInstance[key], myStruct[key], "Asserting #key# From Struct" );
		}

		// populate using scope now
		obj = getMockBox().createMock('coldbox.test-harness.models.formBean');
		obj = populator.populateFromStruct(obj, myStruct, "variables.instance");
		objInstance = obj.getInstance();

		// Assert Population
		for( var key in objInstance ) {
			assertEquals(objInstance[key], myStruct[key], "Asserting by Scope #key# From Struct" );
		}

		// Populate using onMissingMethod
		obj = getMockBox().createMock('coldbox.test-harness.models.formImplicitBean');
		obj = populator.populateFromStruct(target=obj, memento=myStruct, trustedSetter=true);
		objInstance = obj.getInstance();

		// Assert Population
		for( var key in objInstance ) {
			assertEquals( objInstance[key], myStruct[key], "Asserting by Trusted Setter #key# From Struct" );
		}
	}


	public void function testPopulateFromStructWithPrefix() output=false {
		// formBean object: fname,lname,email,initDate
		var obj = getMockBox().createMock('coldbox.test-harness.models.formBean');

		var myStruct = {
			user_fname = "Luis",
			user_lname = "Majano",
			user_email = "test@coldboxframework.com",
			user_initDate = now()
		};

		// Populate From Struct
		obj = populator.populateFromStructWithPrefix( target=obj, memento=myStruct, prefix="user_" );
		var objInstance = obj.getInstance();

		// Assert Population
		for( var key in objInstance ) {
			assertEquals( objInstance[key], myStruct[ "user_" & key ], "Asserting #key# From Struct" );
		}
	}


	public any function testpopulateFromJSON() output=false {
		// formBean object: fname,lname,email,initDate
		var obj = getMockBox().createMock('coldbox.test-harness.models.formBean');

		var myStruct = {
			fname = "Luis",
			lname = "Majano",
			email = "test@coldboxframework.com",
			initDate = dateFormat(now(), "mm/dd/yyy")
		};

		var myJSON = serializeJSON( myStruct );

		// Populate From JSON
		obj = populator.populateFromJSON( obj, myJSON );
		var objInstance = obj.getInstance();

		// Assert Population
		for( var key in objInstance ) {
			assertEquals( objInstance[key], myStruct[key], "Asserting #key# From JSON" );
		}
	}


	public any function testPopulateFromXML() output=false {
		// formBean object: fname,lname,email,initDate
		var obj = getMockBox().createMock('coldbox.test-harness.models.formBean');

		var xml = "
			<root>
				<fname>Luis</fname>
				<lname>Majano</lname>
				<email>test@coldbox.org</email>
				<initDate>#now()#</initDate>
			</root>
		";
		xml = xmlParse( xml );

		obj = populator.populateFromXML(obj, xml);
		var objInstance = obj.getInstance();

		assertEquals( "Luis", obj.getFName() );
		assertEquals( "Majano", obj.getLname() );
		assertEquals( "test@coldbox.org", obj.getEmail() );
	}


	public void function testpopulateFromQuery() output=false {
		// formBean object: fname,lname,email,initDate
		var obj = getMockBox().createMock('coldbox.test-harness.models.formBean');

		var myQuery = QueryNew('fname,lname,email,initDate');
		QueryAddRow(myQuery,1);
		querySetCell(myQuery, "fname", "Sana");
		querySetCell(myQuery, "lname", "Ullah");
		querySetCell(myQuery, "email", "test13@test13.com");
		querySetCell(myQuery, "initDate", now());

		// Populate From Query
		obj = populator.populateFromQuery(obj, myQuery);

		assertEquals( myQuery["fname"][1], obj.getfname() );
		assertEquals( myQuery["lname"][1], obj.getlname() );
		assertEquals( myQuery["email"][1], obj.getemail() );
	}


}
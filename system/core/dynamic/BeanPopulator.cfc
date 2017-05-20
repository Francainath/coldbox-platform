<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author : Luis Majano
Description : This is a bean populator that binds different types of data to a bean.
----------------------------------------------------------------------->
component output="false" hint="This is a bean populator that binds different types of data to a bean." {

	public function init() output="false" hint="Constructor" {
		mixerUtil = createObject("component","coldbox.system.core.dynamic.MixerUtil").init();

		return this;
	}

	/**
	* populateFromJSON: Populate a named or instantiated bean from a json string
	*
	* @target.hint The target to populate
	* @JSONString.hint The JSON string to populate the object with. It has to be valid JSON and also a structure with name-key value pairs
	* @scope.hint Use scope injection instead of setters population
	* @trustedSetter.hint If set to true, the setter method will be called even if it does not exist in the bean
	* @include.hint A list of keys to include in the population
	* @exclude.hint A list of keys to exclude in the population
	* @ignoreEmpty.hint Ignore empty values on populations, great for ORM population
	* @nullEmptyInclude.hint A list of keys to NULL when empty
	* @nullEmptyExclude.hint A list of keys to NOT NULL when empty
	* @composeRelationships.hint Automatically attempt to compose relationships from memento
	*
	* @return A populated beanInstance
	*/
	public function populateFromJSON(
		required any target,
		required string JSONString,
		string scope="",
		boolean trustedSetter=false,
		string include="",
		string exclude="",
		boolean ignoreEmpty=false,
		string nullEmptyInclude="",
		string nullEmptyExclude="",
		boolean composeRelationships=false
	) hint="Populate a named or instantiated bean from a json string" output="false" {
		// Inflate JSON
		arguments.memento = deserializeJSON( arguments.JSONString );

		// populate and return
		return populateFromStruct(argumentCollection=arguments);
	}

	/**
	* populateFromXML: Populate a named or instantiated bean from an XML packet
	*
	* @target.hint The target to populate
	* @xml.hint The XML string or packet
	* @root.hint The XML root element to start from
	* @scope.hint Use scope injection instead of setters population
	* @trustedSetter.hint If set to true, the setter method will be called even if it does not exist in the bean
	* @include.hint A list of keys to include in the population
	* @exclude.hint A list of keys to exclude in the population
	* @ignoreEmpty.hint Ignore empty values on populations, great for ORM population
	* @nullEmptyInclude.hint A list of keys to NULL when empty
	* @nullEmptyExclude.hint A list of keys to NOT NULL when empty
	* @composeRelationships.hint Automatically attempt to compose relationships from memento
	*
	* @return A populated beanInstance
	*/
	public function populateFromXML(
		required any target,
		required any xml,
		string root="",
		string scope="",
		boolean trustedSetter=false,
		string include="",
		string exclude="",
		boolean ignoreEmpty=false,
		string nullEmptyInclude="",
		string nullEmptyExclude="",
		boolean composeRelationships=false
	) hint="Populate a named or instantiated bean from an XML packet" output="false" {
		var key = "";
		var childElements = "";

		// determine XML
		if( isSimpleValue(arguments.xml) ) {
			arguments.xml = xmlParse( arguments.xml );
		}

		// check root
		if( !len(arguments.root) ) {
			arguments.root = "XMLRoot";
		}

		// check children
		if( !structKeyExists(arguments.xml[arguments.root],"XMLChildren") ) {
			return;
		}

		// prepare memento
		arguments.memento = {};

		// iterate and build struct of data
		childElements = arguments.xml[arguments.root].XMLChildren;
		for(var x=1; x lte arrayLen(childElements); x++){
			arguments.memento[ childElements[x].XMLName ] = trim(childElements[x].XMLText);
		}

		return populateFromStruct(argumentCollection=arguments);
	}

	/**
	* populateFromQuery: Populate a named or instantiated bean from query
	*
	* @target.hint The target to populate
	* @query.hint The query to populate the bean object with
	* @rowNumber.hint The query row number to use for population
	* @scope.hint Use scope injection instead of setters population
	* @trustedSetter.hint If set to true, the setter method will be called even if it does not exist in the bean
	* @include.hint A list of keys to include in the population
	* @exclude.hint A list of keys to exclude in the population
	* @ignoreEmpty.hint Ignore empty values on populations, great for ORM population
	* @nullEmptyInclude.hint A list of keys to NULL when empty
	* @nullEmptyExclude.hint A list of keys to NOT NULL when empty
	* @composeRelationships.hint Automatically attempt to compose relationships from memento
	*
	* @return A populated beanInstance
	*/
	public function populateFromQuery(
		required any target,
		required query qry,
		numeric rowNumber=1,
		string scope="",
		boolean trustedSetter=false,
		string include="",
		string exclude="",
		boolean ignoreEmpty=false,
		string nullEmptyInclude="",
		string nullEmptyExclude="",
		boolean composeRelationships=false
	) hint="Populate a named or instantiated bean from query" output="false" {
		//by default to take values from first row of the query
		var row = arguments.rowNumber;
		//columns array
		var cols = listToArray(arguments.qry.columnList);

		arguments.memento = {};

		//build the struct from the query row
		for(var i=1; i lte arraylen(cols); i++) {
			arguments.memento[cols[i]] = arguments.qry[cols[i]][row];
		}

		//populate bean and return
		return populateFromStruct(argumentCollection=arguments);
	}

	/**
	* populateFromQueryWithPrefix: Populates an Object using only specific columns from a query. Useful for performing a query with joins that needs to populate multiple objects
	*
	* @target.hint The target to populate
	* @query.hint The query to populate the bean object with
	* @rowNumber.hint The query row number to use for population
	* @scope.hint Use scope injection instead of setters population
	* @trustedSetter.hint If set to true, the setter method will be called even if it does not exist in the bean
	* @include.hint A list of keys to include in the population
	* @exclude.hint A list of keys to exclude in the population
	* @prefix.hint The prefix used to filter, Example: 'user' would apply to the following formfield: 'user_id' and 'user_name' but not 'address_id'.
	* @ignoreEmpty.hint Ignore empty values on populations, great for ORM population
	* @nullEmptyInclude.hint A list of keys to NULL when empty
	* @nullEmptyExclude.hint A list of keys to NOT NULL when empty
	* @composeRelationships.hint Automatically attempt to compose relationships from memento
	*
	* @return A populated beanInstance
	*/
	public function populateFromQueryWithPrefix(
		required any target,
		required query qry,
		numeric rowNumber,
		string scope="",
		boolean trustedSetter=false,
		string include="",
		string exclude="",
		required string prefix,
		boolean ignoreEmpty=false,
		string nullEmptyInclude="",
		string nullEmptyExclude="",
		boolean composeRelationships=false
	) output=false hint="Populates an Object using only specific columns from a query. Useful for performing a query with joins that needs to populate multiple objects" {
		// Create a struct including only those keys that match the prefix.
		//by default to take values from first row of the query
		var row = arguments.rowNumber;
		var cols = listToArray(arguments.qry.columnList);
		var prefixLength = len(arguments.prefix);
		var trueColumnName = "";

		arguments.memento = structNew();

		//build the struct from the query row
		for(var i=1; i lte arrayLen(cols); i++) {
			if( left(cols[i], prefixLength) eq arguments.prefix ) {
				trueColumnName = right(cols[i], len(cols[i]) - prefixLength);
				arguments.memento[trueColumnName] = arguments.qry[cols[i]][row];
			}
		}

		//populate bean and return
		return populateFromStruct(argumentCollection=arguments);
	}

	/**
	* populateFromStructWithPrefix: Populate a named or instantiated bean from a structure
	*
	* @target.hint The target to populate
	* @memento.hint The structure to populate the object with
	* @scope.hint Use scope injection instead of setters population
	* @trustedSetter.hint If set to true, the setter method will be called even if it does not exist in the bean
	* @include.hint A list of keys to include in the population
	* @exclude.hint A list of keys to exclude in the population
	* @ignoreEmpty.hint Ignore empty values on populations, great for ORM population
	* @nullEmptyInclude.hint A list of keys to NULL when empty
	* @nullEmptyExclude.hint A list of keys to NOT NULL when empty
	* @composeRelationships.hint Automatically attempt to compose relationships from memento
	* @prefix.hint The prefix used to filter, Example: 'user' would apply to the following formfield: 'user_id' and 'user_name' but not 'address_id'.
	*
	* @return A populated beanInstance
	*/
	public function populateFromStructWithPrefix(
		required any target,
		required struct memento,
		string scope="",
		boolean trustedSetter=false,
		string include="",
		string exclude="",
		boolean ignoreEmpty=false,
		string nullEmptyInclude="",
		string nullEmptyExclude="",
		boolean composeRelationships=false,
		required string prefix
	) hint="Populate a named or instantiated bean from a structure" output=false {
		var key = "";
		var newMemento = {};
		var prefixLength = len( arguments.prefix );
		var trueName = "";

		//build the struct from the query row
		for( key in arguments.memento ) {
			// only add prefixed keys
			if ( left( key, prefixLength ) eq arguments.prefix ) {
				trueName = right( key, len( key ) - prefixLength );
				newMemento[ trueName ] = arguments.memento[ key ];
			}
		}

		// override memento
		arguments.memento = newMemento;

		//populate bean and return
		return populateFromStruct( argumentCollection=arguments );
	}

	/**
	* populateFromStruct: Populate a bean from a structure
	*
	* @target.hint The target to populate
	* @memento.hint The structure to populate the object with
	* @scope.hint Use scope injection instead of setters population
	* @trustedSetter.hint If set to true, the setter method will be called even if it does not exist in the bean
	* @include.hint A list of keys to include in the population
	* @exclude.hint A list of keys to exclude in the population
	* @ignoreEmpty.hint Ignore empty values on populations, great for ORM population
	* @nullEmptyInclude.hint A list of keys to NULL when empty
	* @nullEmptyExclude.hint A list of keys to NOT NULL when empty
	* @composeRelationships.hint Automatically attempt to compose relationships from memento
	*
	* @return A populated beanInstance
	*/
	public function populateFromStruct(
		required any target,
		required struct memento,
		string scope,
		boolean trustedSetter=false,
		string include="",
		string exclude="",
		boolean ignoreEmpty=false,
		string nullEmptyInclude="",
		string nullEmptyExclude="",
		boolean composeRelationships=false
	) hint="Populate a named or instantiated bean from a structure" output=false {
		var beanInstance = arguments.target;
		var key = "";
		var pop = true;
		var scopeInjection = false;
		var udfCall = "";
		var args = "";
		var nullValue = false;
		var propertyValue = "";
		var relationalMeta = "";

		try {
			// Determine Method of population
			if( structKeyExists(arguments, "scope") && len(trim(arguments.scope)) neq 0 ) {
				scopeInjection = true;
				mixerUtil.start( beanInstance );
			}

			// If composing relationships, get target metadata
			if( arguments.composeRelationships ) {
				relationalMeta = getRelationshipMetaData( arguments.target );
			}

			// Populate Bean
			for(key in arguments.memento) {
				// init population flag
				pop = true;
				// init nullValue flag and shortcut to property value
				// conditional with StructKeyExist, to prevent language issues with Null value checking of struct keys in ACF
				if ( structKeyExists( arguments.memento, key) ) {
					nullValue = false;
					propertyValue = arguments.memento[ key ];
				} else {
					nullValue = true;
					propertyValue = JavaCast( "null", "" );
				}

				// Include List?
				if( len(arguments.include) && !listFindNoCase(arguments.include, key) ) {
					pop = false;
				}
				// Exclude List?
				if( len(arguments.exclude) && listFindNoCase(arguments.exclude, key) ) {
					pop = false;
				}
				// Ignore Empty? Check added for real Null value
				if( arguments.ignoreEmpty && !IsNull(propertyValue) && isSimpleValue(arguments.memento[key]) and !len( trim( arguments.memento[key] ) ) ) {
					pop = false;
				}

				// Pop?
				if( pop ) {
					if( scopeInjection ) {// Scope Injection?
						beanInstance.populatePropertyMixin(propertyName=key,propertyValue=propertyValue,scope=arguments.scope);
					}
					// Check if setter exists, evaluate is used, so it can call on java/groovy objects
					else if( structKeyExists( beanInstance, "set#key#" ) or arguments.trustedSetter ) {
						// top-level null settings
						if( arguments.nullEmptyInclude == "*" ) {
							nullValue = true;
						}
						if( arguments.nullEmptyExclude == "*" ) {
							nullValue = false;
						}
						// Is property in empty-to-null include list?
						if( ( len( arguments.nullEmptyInclude ) && listFindNoCase( arguments.nullEmptyInclude, key ) ) ) {
							nullValue = true;
						}
						// Is property in empty-to-null exclude list, or is exclude list "*"?
						if( ( len( arguments.nullEmptyExclude ) && listFindNoCase( arguments.nullEmptyExclude, key ) ) ){
							nullValue = false;
						}
						// Is value nullable (e.g., simple, empty string)? If so, set null...
						// short circuit evealuaton of IsNull added, so it won't break IsSimpleValue with Real null values. Real nulls are already set.
						if( !IsNull(propertyValue) && isSimpleValue( propertyValue ) && !len( trim( propertyValue ) ) && nullValue ) {
							propertyValue = JavaCast( "null", "" );
						}

						// If property isn't null, try to compose the relationship
						if( !isNull( propertyValue ) && composeRelationships && structKeyExists( relationalMeta, key ) ) {
							// get valid, known entity name list
							var validEntityNames = structKeyList( ORMGetSessionFactory().getAllClassMetadata() );
							var targetEntityName = "";
							/**
							 * The only info we know about the relationships are the property names and the cfcs
							 * CFC setting can be relative, so can't assume that component lookup will work
							 * APPROACH
							 * 1.) Easy: If property name of relationship is a valid entity name, use that
							 * 2.) Harder: If property name is not a valid entity name (e.g., one-to-many, many-to-many), use cfc name
							 * 3.) Nuclear: If neither above works, try by component meta data lookup. Won't work if using relative paths!!!!
							 */

							if( listFindNoCase( validEntityNames, key ) ) {// 1.) name match
								targetEntityName = key;
							} else if( listFindNoCase( validEntityNames, listLast( relationalMeta[ key ].cfc, "." ) ) ) {// 2.) attempt match on CFC metadata
								targetEntityName = listLast( relationalMeta[ key ].cfc, "." );
							} else {// 3.) component lookup
								try {
									targetEntityName = getComponentMetaData( relationalMeta[ key ].cfc ).entityName;
								} catch( any e ) {
									throw(type="BeanPopulator.PopulateBeanException",
										message="Error populating bean #getMetaData(beanInstance).name# relationship of #key#. The component #relationalMeta[ key ].cfc# could not be found.",
										detail="#e.Detail#<br>#e.message#<br>#e.tagContext.toString()#");
								}
							}
							// if targetEntityName was successfully found
							if( len( targetEntityName) ) {
								// array or struct type (one-to-many, many-to-many)
								if( listContainsNoCase( "one-to-many,many-to-many", relationalMeta[ key ].fieldtype ) ) {
									// Support straight-up lists and convert to array
									if( isSimpleValue( propertyValue ) ) {
										propertyValue = listToArray( propertyValue );
									}
									var relType = structKeyExists( relationalMeta[ key ], "type" ) && relationalMeta[ key ].type != "any" ? relationalMeta[ key ].type : 'array';
									var manyMap = reltype=="struct" ? {} : [];
									// loop over array
									for( var relValue in propertyValue ) {
										// for type of array
										if( relType=="array" ) {
											// add composed relationship to array
											arrayAppend( manyMap, EntityLoadByPK( targetEntityName, relValue ) );
										} else {// for type of struct
											// make sure structKeyColumn is defined in meta
											if( structKeyExists( relationalMeta[ key ], "structKeyColumn" ) ) {
												// load the value
												var item = EntityLoadByPK( targetEntityName, relValue );
												var structKeyColumn = relationalMeta[ key ].structKeyColumn;
												var keyValue = "";
												// try to get struct key value from entity
												if( !isNull( item ) ) {
													try {
														keyValue = evaluate("item.get#structKeyColumn#()");
													} catch( Any e ) {
														throw(type="BeanPopulator.PopulateBeanException",
															message="Error populating bean #getMetaData(beanInstance).name# relationship of #key#. The structKeyColumn #structKeyColumn# could not be resolved.",
															detail="#e.Detail#<br>#e.message#<br>#e.tagContext.toString()#");
													}
												}
												// if the structKeyColumn value was found...
												if( len( keyValue ) ) {
													manyMap[ keyValue ] = item;
												}
											}
										}
									}
									// set main property value to the full array of entities
									propertyValue = manyMap;
								}
								// otherwise, simple value; load relationship (one-to-one, many-to-one)
								else {
									if( isSimpleValue( propertyValue ) && trim( propertyValue ) neq "" ) {
										propertyValue = EntityLoadByPK( targetEntityName, propertyValue );
									}
								}
							} // if target entity name found
						}
						// Populate the property as a null value
						if( isNull( propertyValue ) ) {
							// Finally...set the value
							evaluate( "beanInstance.set#key#( JavaCast( 'null', '' ) )" );
						} else {
							// Populate the property as the value obtained whether simple or related
							evaluate( "beanInstance.set#key#( propertyValue )" );
						}
					}// end if setter or scope injection
				}// end if prop ignored
			}//end for loop
			return beanInstance;
		} catch( Any e ) {
			if( isNull( propertyValue ) ) {
				arguments.keyTypeAsString = "NULL";
			} else if( isObject( propertyValue ) or isCustomFunction( propertyValue )) {
				arguments.keyTypeAsString = getMetaData( propertyValue ).name;
			} else {
				arguments.keyTypeAsString = propertyValue.getClass().toString();
			}
			throw(type="BeanPopulator.PopulateBeanException",
					message="Error populating bean #getMetaData(beanInstance).name# with argument #key# of type #arguments.keyTypeAsString#.",
					detail="#e.Detail#<br>#e.message#<br>#e.tagContext.toString()#");
		}
	}

	/**
	* getRelationshipMetaData: Private function that prepares a structure of target relational meta data
	*
	* @target.hint The target to populate
	*
	* @return A structure of target relational meta data
	*/
	private function getRelationshipMetaData(required any target) output="false" hint="Prepares a structure of target relational meta data" {
		var meta = {};
		// get array of properties
		var stopRecursions= [ "lucee.Component", "railo.Component", "WEB-INF.cftags.component" ];
		var properties = getUtil().getInheritedMetaData( arguments.target, stopRecursions ).properties;

		// loop over properties
		for( var property in properties ) {
			// if property has a name, a fieldtype, and is not the ID, add to maps
			if( structKeyExists( property, "fieldtype" ) &&
				structKeyExists( property, "name" ) &&
				!listFindNoCase( "id,column", property.fieldtype ) ) {
				meta[ property.name ] = property;
			}
		}

		return meta;
	}

	/**
	* getUtil: Private function that returns an instance of the ColdBox core Util
	*
	* @return An instance of the ColdBox core Util
	*/
	private function getUtil() output="false" {
		return createObject("component","coldbox.system.core.util.Util");
	}

}
{
	parser.h : Interfaces, constants and types related to the XML parser.

	See Copyright for the status of this software.

	daniel@veillard.com
}

{
	------------------------------------------------------------------------------
	Translated into pascal with help of h2pas utility from the FreePascal project.
	Petr Kozelka <pkozelka@email.cz>
	------------------------------------------------------------------------------
}

const
	{
		Constants.
	}
	XML_DEFAULT_VERSION = '1.0';

type
	{
		xmlParserInput:

		an xmlParserInput is an input flow for the XML processor.
		Each entity parsed is associated an xmlParserInput (except the
		few predefined ones). This is the case both for internal entities
		- in which case the flow is already completely in memory - or
		external entities - in which case we use the buf structure for
		progressive reading and I18N conversions to the internal UTF-8 format.
	}
	xmlParserInputDeallocate = procedure (p1: PxmlChar);
	xmlParserInputPtr = ^xmlParserInput;

	{ Input buffer  }
	xmlParserInput = record
		buf : xmlParserInputBufferPtr;  { UTF-8 encoded buffer  }
		filename : Pchar;               { The file analyzed, if any  }
		directory : Pchar;              { the directory/base of teh file  }
		base : PxmlChar;                { Base of the array to parse  }
		cur : PxmlChar;                 { Current char being parsed  }
		_end : PxmlChar;                { end of the arry to parse  }
		length : longint;               { length if known  }
		line : longint;                 { Current line  }
		col : longint;                  { Current column  }
		consumed : longint;             { How many xmlChars already consumed  }
		free : xmlParserInputDeallocate;{ function to deallocate the base  }
		encoding : PxmlChar;            { the encoding string for entity  }
		version : PxmlChar;             { the version string for entity  }
		standalone : longint;           { Was that entity marked standalone  }
	end;

	xmlParserInputState =  Longint;
const
	{
		xmlParserInputState:

		The parser is now working also as a state based parser
		The recursive one use the stagte info for entities processing
	}
	XML_PARSER_EOF = -(1);             { nothing is to be parsed }
	XML_PARSER_START = 0;              { nothing has been parsed }
	XML_PARSER_MISC = 1;               { Misc  before int subset }
	XML_PARSER_PI = 2;                 { Whithin a processing instruction }
	XML_PARSER_DTD = 3;                { within some DTD content }
	XML_PARSER_PROLOG = 4;             { Misc  after internal subset }
	XML_PARSER_COMMENT = 5;            { within a comment }
	XML_PARSER_START_TAG = 6;          { within a start tag }
	XML_PARSER_CONTENT = 7;            { within the content }
	XML_PARSER_CDATA_SECTION = 8;      { within a CDATA section }
	XML_PARSER_END_TAG = 9;            { within a closing tag }
	XML_PARSER_ENTITY_DECL = 10;       { within an entity declaration }
	XML_PARSER_ENTITY_VALUE = 11;      { within an entity value in a decl }
	XML_PARSER_ATTRIBUTE_VALUE = 12;   { within an attribute value }
	XML_PARSER_SYSTEM_LITERAL = 13;    { within a SYSTEM value }
	XML_PARSER_EPILOG = 14;            { the Misc  after the last end tag }
	XML_PARSER_IGNORE = 15;            { within an IGNORED section }

	{
		XML_DETECT_IDS:

		Bit in the loadsubset context field to tell to do ID/REFs lookups
		Use it to initialize xmlLoadExtDtdDefaultValue
	}

	XML_DETECT_IDS = 2;
	{
		XML_COMPLETE_ATTRS:

		Bit in the loadsubset context field to tell to do complete the
		elements attributes lists with the ones defaulted from the DTDs
		Use it to initialize xmlLoadExtDtdDefaultValue
	}

	XML_COMPLETE_ATTRS = 4;
	{
		xmlParserCtxt:

		The parser context.
		NOTE This doesn't completely defines the parser state, the (current ?)
				design of the parser uses recursive function calls since this allow
				and easy mapping from the production rules of the specification
				to the actual code. The drawback is that the actual function call
				also reflect the parser state. However most of the parsing routines
				takes as the only argument the parser context pointer, so migrating
				to a state based parser for progressive parsing shouldn't be too hard.
	}
type
	xmlSAXHandlerPtr = ^xmlSAXHandler;
	{
		xmlParserNodeInfo:

		the parser can be asked to collect Node informations, i.e. at what
		place in the file they were detected.
		NOTE: This is off by default and not very well tested.
	}
	xmlParserNodeInfoPtr = ^xmlParserNodeInfo;

	{ Position & line # that text that created the node begins & ends on  }
	xmlParserNodeInfo = record
		node : xmlNodePtr;
		begin_pos : dword;
		begin_line : dword;
		end_pos : dword;
		end_line : dword;
	end;

	xmlParserNodeInfoSeqPtr = ^xmlParserNodeInfoSeq;
	xmlParserNodeInfoSeq = record
		maximum : dword;
		length : dword;
		buffer : ^xmlParserNodeInfo;
	end;

	xmlParserCtxtPtr = ^xmlParserCtxt;
	xmlParserCtxt = record
		sax : xmlSAXHandlerPtr;               { The SAX handler  }
		userData : pointer;                   { For SAX interface only, used by DOM build  }
		myDoc : xmlDocPtr;                    { the document being built  }
		wellFormed : longint;                 { is the document well formed  }
		replaceEntities : longint;            { shall we replace entities ?  }
		version : PxmlChar;                   { the XML version string  }
		encoding : PxmlChar;                  { the declared encoding, if any  }
		standalone : longint;                 { standalone document  }
		html : longint;                       { an HTML(1)/Docbook(2) document  }
		{ Input stream stack  }
		input : xmlParserInputPtr;            { Current input stream  }
		inputNr : longint;                    { Number of current input streams  }
		inputMax : longint;                   { Max number of input streams  }
		{ stack of inputs  }
		inputTab : ^xmlParserInputPtr;        { Node analysis stack only used for DOM building  }
		node : xmlNodePtr;                    { Current parsed Node  }
		nodeNr : longint;                     { Depth of the parsing stack  }
		nodeMax : longint;                    { Max depth of the parsing stack  }
		nodeTab : ^xmlNodePtr;                { array of nodes  }
		record_info : longint;                { Whether node info should be kept  }
		node_seq : xmlParserNodeInfoSeq;      { info about each node parsed  }
		errNo : longint;                      { error code  }
		hasExternalSubset : longint;          { reference and external subset  }
		hasPErefs : longint;                  { the internal subset has PE refs  }
		external_ : longint;                  { are we parsing an external entity  }
		valid : longint;                      { is the document valid  }
		validate : longint;                   { shall we try to validate ?  }
		vctxt : xmlValidCtxt;                 { The validity context  }
		instate : xmlParserInputState;        { current type of input  }
		token : longint;                      { next char look-ahead  }
		directory : Pchar;                    { the data directory  }
		{ Node name stack  }
		name : PxmlChar;                      { Current parsed Node  }
		nameNr : longint;                     { Depth of the parsing stack  }
		nameMax : longint;                  	{ Max depth of the parsing stack  }
		nameTab : ^PxmlChar;                  { array of nodes  }
		nbChars : longint;                    { number of xmlChar processed  }
		checkIndex : longint;                 { used by progressive parsing lookup  }
		keepBlanks : longint;                 { ugly but ...  }
		disableSAX : longint;                 { SAX callbacks are disabled  }
		inSubset : longint;                   { Parsing is in int 1/ext 2 subset  }
		intSubName : PxmlChar;                { name of subset  }
		extSubURI : PxmlChar;                 { URI of external subset  }
		extSubSystem : PxmlChar;              { SYSTEM ID of external subset  }
		{ xml:space values  }
		space : Plongint;                     { Should the parser preserve spaces  }
		spaceNr : longint;                    { Depth of the parsing stack  }
		spaceMax : longint;                   { Max depth of the parsing stack  }
		spaceTab : Plongint;                  { array of space infos  }
		depth : longint;                      { to prevent entity substitution loops  }
		entity : xmlParserInputPtr;           { used to check entities boundaries  }
		charset : longint;                    { encoding of the in-memory content - actually an xmlCharEncoding  }
		nodelen : longint;                    { Those two fields are there to  }
		nodemem : longint;                    { Speed up large node parsing  }
		pedantic : longint;                   { signal pedantic warnings  }
		_private : pointer;                   { For user data, libxml won't touch it  }
		loadsubset : longint;                 { should the external subset be loaded  }
	end;

	{
		xmlSAXLocator:
		a SAX Locator.
	}
	xmlSAXLocatorPtr = ^xmlSAXLocator;
	xmlSAXLocator = record
		getPublicId : function (ctx:pointer):PxmlChar;cdecl;
		getSystemId : function (ctx:pointer):PxmlChar;
		getLineNumber : function (ctx:pointer):longint;
		getColumnNumber : function (ctx:pointer):longint;
	end;

	{
		xmlSAXHandler:

		a SAX handler is bunch of callbacks called by the parser when processing
		of the input generate data or structure informations.
	}
	resolveEntitySAXFunc         = function  (ctx: pointer; publicId, systemId: PxmlChar):xmlParserInputPtr; cdecl;
	internalSubsetSAXFunc        = procedure (ctx: pointer; name, ExternalID, SystemID: PxmlChar); cdecl;
	externalSubsetSAXFunc        = procedure (ctx: pointer; name, ExternalID, SystemID: PxmlChar); cdecl;
	getEntitySAXFunc             = function  (ctx: pointer; name: PxmlChar): xmlEntityPtr; cdecl;
	getParameterEntitySAXFunc    = function  (ctx: pointer; name: PxmlChar): xmlEntityPtr; cdecl;
	entityDeclSAXFunc            = procedure (ctx: pointer; name: PxmlChar; aEntityType: integer; publicID, systemID, content: PxmlChar); cdecl;
	notationDeclSAXFunc          = procedure (ctx: pointer; name: PxmlChar; publicID, systemID: PxmlChar); cdecl;
	attributeDeclSAXFunc         = procedure (ctx: pointer; elem, name: PxmlChar; aType, def: integer; defaultValue: PxmlChar; tree: xmlEnumerationPtr); cdecl;
	elementDeclSAXFunc           = procedure (ctx: pointer; name: PxmlChar; aType: integer; content: xmlElementContentPtr); cdecl;
	unparsedEntityDeclSAXFunc    = procedure (ctx: pointer; name: PxmlChar; publicID, systemID, notationName: PxmlChar); cdecl;
	setDocumentLocatorSAXFunc    = procedure (ctx: pointer; loc: xmlSAXLocator); cdecl;
	startDocumentSAXFunc         = procedure (ctx: pointer); cdecl;
	endDocumentSAXFunc           = procedure (ctx: pointer); cdecl;
	startElementSAXFunc          = procedure (ctx: pointer; name: PxmlChar; atts: PPxmlChar); cdecl;
	endElementSAXFunc            = procedure (ctx: pointer; name: PxmlChar); cdecl;
	attributeSAXFunc             = procedure (ctx: pointer; name, value: PxmlChar); cdecl;
	referenceSAXFunc             = procedure (ctx: pointer; name: PxmlChar); cdecl;
	charactersSAXFunc            = procedure (ctx: pointer; ch: PxmlChar; len: integer); cdecl;
	ignorableWhitespaceSAXFunc   = procedure (ctx: pointer; ch: PxmlChar; len: integer); cdecl;
	processingInstructionSAXFunc = procedure (ctx: pointer; target, data: PxmlChar); cdecl;
	commentSAXFunc               = procedure (ctx: pointer; value: PxmlChar); cdecl;
	cdataBlockSAXFunc            = procedure (ctx: pointer; value: PxmlChar; len: integer); cdecl;
	warningSAXFunc               = procedure (ctx: pointer; msg: PxmlChar); cdecl; //varargs;
	errorSAXFunc                 = procedure (ctx: pointer; msg: PxmlChar); cdecl; //varargs;
	fatalErrorSAXFunc            = procedure (ctx: pointer; msg: PxmlChar); cdecl; //varargs;
	isStandaloneSAXFunc          = function  (ctx: pointer): integer; cdecl;
	hasInternalSubsetSAXFunc     = function  (ctx: pointer): integer; cdecl;
	hasExternalSubsetSAXFunc     = function  (ctx: pointer): integer; cdecl;

	xmlSAXHandler = record
		internalSubset : internalSubsetSAXFunc;
		isStandalone : isStandaloneSAXFunc;
		hasInternalSubset : hasInternalSubsetSAXFunc;
		hasExternalSubset : hasExternalSubsetSAXFunc;
		resolveEntity : resolveEntitySAXFunc;
		getEntity : getEntitySAXFunc;
		entityDecl : entityDeclSAXFunc;
		notationDecl : notationDeclSAXFunc;
		attributeDecl : attributeDeclSAXFunc;
		elementDecl : elementDeclSAXFunc;
		unparsedEntityDecl : unparsedEntityDeclSAXFunc;
		setDocumentLocator : setDocumentLocatorSAXFunc;
		startDocument : startDocumentSAXFunc;
		endDocument : endDocumentSAXFunc;
		startElement : startElementSAXFunc;
		endElement : endElementSAXFunc;
		reference : referenceSAXFunc;
		characters : charactersSAXFunc;
		ignorableWhitespace : ignorableWhitespaceSAXFunc;
		processingInstruction : processingInstructionSAXFunc;
		comment : commentSAXFunc;
		warning : warningSAXFunc;
		error : errorSAXFunc;
		fatalError : fatalErrorSAXFunc;
		getParameterEntity : getParameterEntitySAXFunc;
		cdataBlock : cdataBlockSAXFunc;
		externalSubset : externalSubsetSAXFunc;
	end;

	{
		xmlExternalEntityLoader:
		@URL: The System ID of the resource requested
		@ID: The Public ID of the resource requested
		@xmlParserCtxtPtr: the XML parser context

		External entity loaders types
	}
	xmlExternalEntityLoader = function (URL, ID: PChar; context: xmlParserCtxtPtr): xmlParserInputPtr;

	{
		Global variables: just the default SAX interface tables and XML
		version infos.
	}
(* TODO somehow
LIBXML_DLL_IMPORT extern const char *xmlParserVersion;
LIBXML_DLL_IMPORT extern xmlSAXLocator xmlDefaultSAXLocator;
LIBXML_DLL_IMPORT extern xmlSAXHandler xmlDefaultSAXHandler;
LIBXML_DLL_IMPORT extern xmlSAXHandler htmlDefaultSAXHandler;
LIBXML_DLL_IMPORT extern xmlSAXHandler docbDefaultSAXHandler;
LIBXML_DLL_IMPORT extern int xmlSubstituteEntitiesDefaultValue;
LIBXML_DLL_IMPORT extern int xmlGetWarningsDefaultValue;
*)

{
	Init/Cleanup
}
procedure xmlInitParser;cdecl;external LIBXML2_SO;
procedure xmlCleanupParser;cdecl;external LIBXML2_SO;

{
	Input functions
}
function  xmlParserInputRead(aIn:xmlParserInputPtr; len:longint):longint;cdecl;external LIBXML2_SO;
function  xmlParserInputGrow(aIn:xmlParserInputPtr; len:longint):longint;cdecl;external LIBXML2_SO;

{
	xmlChar handling
}
function  xmlStrdup(cur:PxmlChar):PxmlChar;cdecl;external LIBXML2_SO;
function  xmlStrndup(cur:PxmlChar; len:longint):PxmlChar;cdecl;external LIBXML2_SO;
function  xmlCharStrndup(cur:Pchar; len:longint):PxmlChar;cdecl;external LIBXML2_SO;
function  xmlCharStrdup(cur:Pchar):PxmlChar;cdecl;external LIBXML2_SO;
function  xmlStrsub(str:PxmlChar; start:longint; len:longint):PxmlChar;cdecl;external LIBXML2_SO;
function  xmlStrchr(str:PxmlChar; val:xmlChar):PxmlChar;cdecl;external LIBXML2_SO;
function  xmlStrstr(str:PxmlChar; val:PxmlChar):PxmlChar;cdecl;external LIBXML2_SO;
function  xmlStrcasestr(str:PxmlChar; val:PxmlChar):PxmlChar;cdecl;external LIBXML2_SO;
function  xmlStrcmp(str1:PxmlChar; str2:PxmlChar):longint;cdecl;external LIBXML2_SO;
function  xmlStrncmp(str1:PxmlChar; str2:PxmlChar; len:longint):longint;cdecl;external LIBXML2_SO;
function  xmlStrcasecmp(str1:PxmlChar; str2:PxmlChar):longint;cdecl;external LIBXML2_SO;
function  xmlStrncasecmp(str1:PxmlChar; str2:PxmlChar; len:longint):longint;cdecl;external LIBXML2_SO;
function  xmlStrEqual(str1:PxmlChar; str2:PxmlChar):longint;cdecl;external LIBXML2_SO;
function  xmlStrlen(str:PxmlChar):longint;cdecl;external LIBXML2_SO;
function  xmlStrcat(cur:PxmlChar; add:PxmlChar):PxmlChar;cdecl;external LIBXML2_SO;
function  xmlStrncat(cur:PxmlChar; add:PxmlChar; len:longint):PxmlChar;cdecl;external LIBXML2_SO;

{
	Basic parsing Interfaces
}
function  xmlParseDoc(cur:PxmlChar):xmlDocPtr;cdecl;external LIBXML2_SO;
function  xmlParseMemory(buffer:Pchar; size:longint):xmlDocPtr;cdecl;external LIBXML2_SO;
function  xmlParseFile(filename:Pchar):xmlDocPtr;cdecl;external LIBXML2_SO;
function  xmlSubstituteEntitiesDefault(val:longint):longint;cdecl;external LIBXML2_SO;
function  xmlKeepBlanksDefault(val:longint):longint;cdecl;external LIBXML2_SO;
procedure xmlStopParser(ctxt:xmlParserCtxtPtr);cdecl;external LIBXML2_SO;
function  xmlPedanticParserDefault(val:longint):longint;cdecl;external LIBXML2_SO;

{
	Recovery mode
}
function  xmlRecoverDoc(cur:PxmlChar):xmlDocPtr;cdecl;external LIBXML2_SO;
function  xmlRecoverMemory(buffer:Pchar; size:longint):xmlDocPtr;cdecl;external LIBXML2_SO;
function  xmlRecoverFile(filename:Pchar):xmlDocPtr;cdecl;external LIBXML2_SO;

{
	Less common routines and SAX interfaces
}
function  xmlParseDocument(ctxt:xmlParserCtxtPtr):longint;cdecl;external LIBXML2_SO;
function  xmlParseExtParsedEnt(ctxt:xmlParserCtxtPtr):longint;cdecl;external LIBXML2_SO;
function  xmlSAXParseDoc(sax:xmlSAXHandlerPtr; cur:PxmlChar; recovery:longint):xmlDocPtr;cdecl;external LIBXML2_SO;
function  xmlSAXUserParseFile(sax:xmlSAXHandlerPtr; user_data:pointer; filename:Pchar):longint;cdecl;external LIBXML2_SO;
function  xmlSAXUserParseMemory(sax:xmlSAXHandlerPtr; user_data:pointer; buffer:Pchar; size:longint):longint;cdecl;external LIBXML2_SO;
function  xmlSAXParseMemory(sax:xmlSAXHandlerPtr; buffer:Pchar; size:longint; recovery:longint):xmlDocPtr;cdecl;external LIBXML2_SO;
function  xmlSAXParseFile(sax:xmlSAXHandlerPtr; filename:Pchar; recovery:longint):xmlDocPtr;cdecl;external LIBXML2_SO;
function  xmlSAXParseEntity(sax:xmlSAXHandlerPtr; filename:Pchar):xmlDocPtr;cdecl;external LIBXML2_SO;
function  xmlParseEntity(filename:Pchar):xmlDocPtr;cdecl;external LIBXML2_SO;
function  xmlParseDTD(ExternalID:PxmlChar; SystemID:PxmlChar):xmlDtdPtr;cdecl;external LIBXML2_SO;
function  xmlSAXParseDTD(sax:xmlSAXHandlerPtr; ExternalID:PxmlChar; SystemID:PxmlChar):xmlDtdPtr;cdecl;external LIBXML2_SO;
function  xmlIOParseDTD(sax:xmlSAXHandlerPtr; input:xmlParserInputBufferPtr; enc:xmlCharEncoding):xmlDtdPtr;cdecl;external LIBXML2_SO;
function  xmlParseBalancedChunkMemory(doc:xmlDocPtr; sax:xmlSAXHandlerPtr; user_data:pointer; depth:longint; aString:PxmlChar; list:PxmlNodePtr):longint;cdecl;external LIBXML2_SO;
function  xmlParseExternalEntity(doc:xmlDocPtr; sax:xmlSAXHandlerPtr; user_data:pointer; depth:longint; URL:PxmlChar; ID:PxmlChar; list:PxmlNodePtr):longint;cdecl;external LIBXML2_SO;
function  xmlParseCtxtExternalEntity(ctx:xmlParserCtxtPtr; URL:PxmlChar; ID:PxmlChar; list:PxmlNodePtr):longint;cdecl;external LIBXML2_SO;

{
	SAX initialization routines
}
(* these are in libxml_SAX.inc
procedure xmlDefaultSAXHandlerInit;cdecl;external LIBXML2_SO;
procedure htmlDefaultSAXHandlerInit;cdecl;external LIBXML2_SO;
*)

{
	Parser contexts handling.
}
procedure xmlInitParserCtxt(ctxt:xmlParserCtxtPtr);cdecl;external LIBXML2_SO;
procedure xmlClearParserCtxt(ctxt:xmlParserCtxtPtr);cdecl;external LIBXML2_SO;
procedure xmlFreeParserCtxt(ctxt:xmlParserCtxtPtr);cdecl;external LIBXML2_SO;
procedure xmlSetupParserForBuffer(ctxt:xmlParserCtxtPtr; buffer:PxmlChar; filename:Pchar);cdecl;external LIBXML2_SO;
function  xmlCreateDocParserCtxt(cur:PxmlChar):xmlParserCtxtPtr;cdecl;external LIBXML2_SO;

{
	Reading/setting optional parsing features.
}
function  xmlGetFeaturesList(len:Plongint; result:PPchar):longint;cdecl;external LIBXML2_SO;
function  xmlGetFeature(ctxt:xmlParserCtxtPtr; name:Pchar; result:pointer):longint;cdecl;external LIBXML2_SO;
function  xmlSetFeature(ctxt:xmlParserCtxtPtr; name:Pchar; value:pointer):longint;cdecl;external LIBXML2_SO;
{
	Interfaces for the Push mode
}
function  xmlCreatePushParserCtxt(sax:xmlSAXHandlerPtr; user_data:pointer; chunk:Pchar; size:longint; filename:Pchar):xmlParserCtxtPtr;cdecl;external LIBXML2_SO;
function  xmlParseChunk(ctxt:xmlParserCtxtPtr; chunk:Pchar; size:longint; terminate:longint):longint;cdecl;external LIBXML2_SO;
{
	Special I/O mode
}
function  xmlCreateIOParserCtxt(sax:xmlSAXHandlerPtr; user_data:pointer; ioread:xmlInputReadCallback; ioclose:xmlInputCloseCallback; ioctx:pointer; enc:xmlCharEncoding):xmlParserCtxtPtr;cdecl;external LIBXML2_SO;
function  xmlNewIOInputStream(ctxt:xmlParserCtxtPtr; input:xmlParserInputBufferPtr; enc:xmlCharEncoding):xmlParserInputPtr;cdecl;external LIBXML2_SO;
{
	Node infos
}
function  xmlParserFindNodeInfo(ctxt:xmlParserCtxtPtr; node:xmlNodePtr):xmlParserNodeInfoPtr;cdecl;external LIBXML2_SO;
procedure xmlInitNodeInfoSeq(seq:xmlParserNodeInfoSeqPtr);cdecl;external LIBXML2_SO;
procedure xmlClearNodeInfoSeq(seq:xmlParserNodeInfoSeqPtr);cdecl;external LIBXML2_SO;
function  xmlParserFindNodeInfoIndex(seq:xmlParserNodeInfoSeqPtr; node:xmlNodePtr):dword;cdecl;external LIBXML2_SO;
procedure xmlParserAddNodeInfo(ctxt:xmlParserCtxtPtr; info:xmlParserNodeInfoPtr);cdecl;external LIBXML2_SO;
{
	External entities handling actually implemented in xmlIO
}
procedure xmlSetExternalEntityLoader(f:xmlExternalEntityLoader);cdecl;external LIBXML2_SO;
function  xmlGetExternalEntityLoader:xmlExternalEntityLoader;cdecl;external LIBXML2_SO;
function  xmlLoadExternalEntity(URL:Pchar; ID:Pchar; context:xmlParserCtxtPtr):xmlParserInputPtr;cdecl;external LIBXML2_SO;

unit libxmldom;
//$Id: libxmldom.pas,v 1.82 2002-01-27 21:59:42 pkozelka Exp $

{
   ------------------------------------------------------------------------------
   This unit is an object-oriented wrapper for libxml2.
   It implements the interfaces defined in dom2.pas.

   Author:
   Uwe Fechner <ufechner@4commerce.de>
   .
   Some Code by:
   Martijn Brinkers
   Petr Kozelka

     Copyright:
     4commerce technologies AG
     Kamerbalken 10-14
     22525 Hamburg, Germany

    Published under a double license:
    a) the GNU Library General Public License: 
       http://www.gnu.org/copyleft/lgpl.html
    b) the Mozilla Public License:
       http://www.mozilla.org/MPL/MPL-1.1.html
   ------------------------------------------------------------------------------
}

// implemented methods:
// ====================
// see tests_libxml2.txt

// Partly supported by libxml2:
// IDomPersist
//
// Not Supported by libxml2:
// IDomNodeEx, IDomParseError (extended interfaces, not part of dom-spec)
// Attr.ownerElement

interface

uses
  {$ifdef VER130} //Delphi 5
    unicode,
  {$endif}
  classes,
  xdom2,
  libxml2,
  sysutils;

const
  SLIBXML = 'LIBXML';  { Do not localize }

type
  TGDOMChildNodeList = class;
  TGDOMElement = class;

  { TGDOMObject }

  TGDOMObject = class(TInterfacedObject)
  protected
    procedure DomAssert(aCondition: boolean; aErrorCode:integer; aMsg: WideString='');
  public
    function SafeCallException(ExceptObject: TObject; ExceptAddr: Pointer): HRESULT; override;
  end;

  { TGDOMImplementation }

  TGDOMImplementation = class(TGDOMObject, IDomImplementation)
  private
    class function getInstance(aFreeThreading: boolean): IDomImplementation;
  protected //IDomImplementation
    function hasFeature(const feature, version: DomString): Boolean;
    function createDocumentType(const qualifiedName, publicId, systemId: DomString): IDomDocumentType;
    function createDocument(const namespaceURI, qualifiedName: DomString; doctype: IDomDocumentType): IDomDocument;
  public
  end;

  { TGDOMNode }

  TGDOMNodeClass = class of TGDOMNode;
  TGDOMNode = class(TGDOMObject, IDomNode, ILibXml2Node, IDomNodeSelect)
  private
    FGNode: xmlNodePtr;
    FChildNodes: TGDOMChildNodeList; // non-counted reference
    function  returnNullDomNode: IDomNode;
    function  returnEmptyString: DomString;
  protected //ILibXml2Node
    function  LibXml2NodePtr: xmlNodePtr;
  protected //IDomNode
    function  get_nodeName: DomString;
    function  get_nodeValue: DomString;
    procedure set_nodeValue(const value: DomString);
    function  get_nodeType: DOMNodeType;
    function  get_parentNode: IDomNode;
    function  get_childNodes: IDomNodeList;
    function  get_firstChild: IDomNode;
    function  get_lastChild: IDomNode;
    function  get_previousSibling: IDomNode;
    function  get_nextSibling: IDomNode;
    function  get_attributes: IDomNamedNodeMap;
    function  get_ownerDocument: IDomDocument; virtual;
    function  get_namespaceURI: DomString;
    function  get_prefix: DomString;
    procedure set_Prefix(const prefix : DomString);
    function  get_localName: DomString;
    function  insertBefore(const newChild, refChild: IDomNode): IDomNode;
    function  replaceChild(const newChild, oldChild: IDomNode): IDomNode;
    function  removeChild(const childNode: IDomNode): IDomNode;
    function  appendChild(const newChild: IDomNode): IDomNode;
    function  hasChildNodes: Boolean;
    function  hasAttributes : Boolean;
    function  cloneNode(deep: Boolean): IDomNode;
    procedure normalize;
  protected //IDomNodeSelect
    function  selectNode(const nodePath: WideString): IDomNode;
    function  selectNodes(const nodePath: WideString): IDomNodeList;
    procedure RegisterNS(const prefix,URI: DomString);
  protected
    constructor Create(aLibXml2Node: pointer); virtual;
    function  requestNodePtr: xmlNodePtr; virtual;
    //function supports(const feature, version: DomString): Boolean;
    function  isSupported(const feature, version: DomString): Boolean;
    function  IsReadOnly: boolean;
    function  IsAncestorOrSelf(newNode:xmlNodePtr): boolean; //new
    property  GNode: xmlNodePtr read FGNode;
  public
    destructor Destroy; override;
  end;

  { TGDOMChildNodeList }

  TGDOMChildNodeList = class(TGDOMObject, IDomNodeList)
  private
    FOwnerNode: TGDOMNode; // non-counted reference
  protected //IDomNodeList
    function get_item(index: Integer): IDomNode;
    function get_length: Integer;
  protected
    constructor Create(aOwnerNode: TGDOMNode);
  public
    destructor Destroy; override;
  end;

  { TGDOMXPathNodeList }

  TGDOMXPathNodeList = class(TGDOMObject, IDomNodeList)
  private
    FXPathCtxt: xmlXPathContextPtr;
    FXPathObj: xmlXPathObjectPtr;
    FQuery: String;
    procedure Eval;
  protected //IDomNodeList
    function get_item(index: Integer): IDomNode;
    function get_length: Integer;
  protected
    constructor Create(aBaseNode: TGDOMNode; aQuery: String);
  public
    destructor Destroy; override;
  end;

  { TGDOMAttributes }

  TGDOMAttributes = class(TGDOMObject, IDomNamedNodeMap)
  private
    FOwnerElement: TGDOMElement; // non-counted reference
  protected //IDomNamedNodeMap
    function get_item(index: Integer): IDomNode;
    function get_length: Integer;
    function getNamedItem(const name: DomString): IDomNode;
    function setNamedItem(const newItem: IDomNode): IDomNode;
    function removeNamedItem(const name: DomString): IDomNode;
    function getNamedItemNS(const namespaceURI, localName: DomString): IDomNode;
    function setNamedItemNS(const newItem: IDomNode): IDomNode;
    function removeNamedItemNS(const namespaceURI, localName: DomString): IDomNode;
  protected
    constructor Create(aOwnerElement: TGDOMElement);
  public
    destructor Destroy; override;
  end;

  { TGDOMAttr }

  TGDOMAttr = class(TGDOMNode, IDomNode, IDomAttr)
  protected //IDomNode
//    procedure set_nodeValue(const value: DomString);
    function  IDomNode.get_parentNode = returnNullDomNode;
    function  IDomNode.get_firstChild = returnNullDomNode;
    function  IDomNode.get_lastChild = returnNullDomNode;
    function  IDomNode.get_previousSibling = returnNullDomNode;
    function  IDomNode.get_nextSibling = returnNullDomNode;
  protected //IDomAttr
    function  IDomAttr.get_name = get_nodeName;
    function  get_specified: Boolean;
    function  IDomAttr.get_value = get_nodeValue;
    procedure IDomAttr.set_value = set_nodeValue;
    function  get_ownerElement: IDomElement;
  end;

  { TGDOMElement }

  TGDOMElement = class(TGDOMNode, IDomElement, IDomNode)
  private
    FAttributes: TGDOMAttributes; // non-counted reference
  protected //IDomNode
    function  get_attributes: IDomNamedNodeMap;
  protected //IDomElement
    function  IDomElement.get_tagName = get_localName;
    function  getAttribute(const name: DomString): DomString;
    procedure setAttribute(const name, value: DomString);
    procedure removeAttribute(const name: DomString);
    function  getAttributeNode(const name: DomString): IDomAttr;
    function  IDomElement.setAttributeNode = setAttributeNodeNS;
    function  removeAttributeNode(const oldAttr: IDomAttr):IDomAttr;
    function  getElementsByTagName(const name: DomString): IDomNodeList;
    function  getAttributeNS(const namespaceURI, localName: DomString): DomString;
    procedure setAttributeNS(const namespaceURI, qualifiedName, value: DomString);
    procedure removeAttributeNS(const namespaceURI, localName: DomString);
    function  getAttributeNodeNS(const namespaceURI, localName: DomString): IDomAttr;
    function  setAttributeNodeNS(const newAttr: IDomAttr): IDomAttr;
    function  getElementsByTagNameNS(const namespaceURI, localName: DomString): IDomNodeList;
    function  hasAttribute(const name: DomString): Boolean;
    function  hasAttributeNS(const namespaceURI, localName: DomString): Boolean;
  protected
    constructor Create(aLibXml2Node: pointer); override;
  public
    destructor Destroy; override;
  end;

  { TGDOMCharacterData }

  TGDOMCharacterData = class(TGDOMNode, IDomCharacterData, IDomNode)
  private
  protected // IDomCharacterData
    function  IDomCharacterData.get_data = get_nodeValue;
    procedure IDomCharacterData.set_data = set_nodeValue;
    function  get_length: Integer;
    function  substringData(offset, count: Integer): DomString;
    procedure appendData(const data: DomString);
    procedure insertData(offset: Integer; const data: DomString);
    procedure deleteData(offset, count: Integer);
    procedure replaceData(offset, count: Integer; const data: DomString);
  public
  end;

  { TGDOMText }

  TGDOMText = class(TGDOMCharacterData, IDomText, IDomCharacterData, IDomNode)
  protected // IDomCharacterData
    function  IDomCharacterData.get_data = get_nodeValue;
    procedure IDomCharacterData.set_data = set_nodeValue;
  protected //IDomText
    function  IDomText.get_data = get_nodeValue;
    procedure IDomText.set_data = set_nodeValue;
    function splitText(offset: Integer): IDomText;
  end;

  { TGDOMComment }

  TGDOMComment = class(TGDOMCharacterData, IDomComment, IDomCharacterData, IDomNode)
  protected // IDomCharacterData
    function  IDomCharacterData.get_data = get_nodeValue;
    procedure IDomCharacterData.set_data = set_nodeValue;
  protected //IDomComment
    function  IDomComment.get_data = get_nodeValue;
    procedure IDomComment.set_data = set_nodeValue;
  end;

  { TGDOMCDATASection }

  TGDOMCDATASection = class(TGDOMText, IDomCDataSection, IDomCharacterData, IDomNode)
  protected // IDomCharacterData
    function  IDomCharacterData.get_data = get_nodeValue;
    procedure IDomCharacterData.set_data = set_nodeValue;
  protected //IDomCDataSection
    function  IDomCDataSection.get_data = get_nodeValue;
    procedure IDomCDataSection.set_data = set_nodeValue;
  end;

  { TGDOMDocumentType }

  TGDOMDocumentType = class(TGDOMNode, IDomDocumentType)
  private
    function GetGDocumentType: xmlDtdPtr;
  protected //IDomDocumentType
    function get_name: DomString;
    function get_entities: IDomNamedNodeMap;
    function get_notations: IDomNamedNodeMap;
    function get_publicId: DomString;
    function get_systemId: DomString;
    function get_internalSubset: DomString;
  end;

  { TGDOMNotation }

  TGDOMNotation = class(TGDOMNode, IDomNode, IDomNotation)
  protected //IDomNode
    function  IDomNode.get_parentNode = returnNullDomNode;
  protected //IDomNotation
    function get_publicId: DomString;
    function get_systemId: DomString;
  end;

  { TGDOMEntity }

  TGDOMEntity = class(TGDOMNode, IDomNode, IDomEntity)
  protected //IDomNode
    function  IDomNode.get_parentNode = returnNullDomNode;
  protected //IDomEntity
    function get_publicId: DomString;
    function get_systemId: DomString;
    function get_notationName: DomString;
  end;

  { TGDOMEntityReference }

  TGDOMEntityReference = class(TGDOMNode, IDomEntityReference, IDomNode)
  end;

  { TGDOMProcessingInstruction }

  TGDOMProcessingInstruction = class(TGDOMNode, IDomProcessingInstruction)
  private
  protected //IDomProcessingInstruction
    function  IDomProcessingInstruction.get_target = get_nodeName;
    function  IDomProcessingInstruction.get_data = get_nodeValue;
    procedure IDomProcessingInstruction.set_data = set_nodeValue;
  public
  end;

  { TGDOMDocument }

  TGDOMDocument = class(TGDOMNode, IDomDocument, IDomParseOptions, IDomPersist, IDomNode)
  private
    FGDOMImpl: IDomImplementation;
    FAsync: boolean;              //for compatibility, not really supported
    FpreserveWhiteSpace: boolean; //difficult to support
    FresolveExternals: boolean;   //difficult to support
    Fvalidate: boolean;           //check if default is ok
    FFlyingNodes: TList;          // on-demand created list of nodes not attached to the document tree (=they have no parent)
  protected //IDomNode
    function  get_nodeName: DomString;
    function  IDomNode.get_nodeValue = returnEmptyString;
    procedure set_nodeValue(const value: DomString);
    function  get_nodeType: DOMNodeType;
    function  IDomNode.get_parentNode = returnNullDomNode;
    function  IDomNode.get_previousSibling = returnNullDomNode;
    function  IDomNode.get_nextSibling = returnNullDomNode;
    function  get_ownerDocument: IDomDocument; override;
    function  IDomNode.get_namespaceURI = returnEmptyString;
    function  IDomNode.get_prefix = returnEmptyString;
    function  IDomNode.get_localName = returnEmptyString;
  protected //IDomDocument
    function  get_doctype: IDomDocumentType;
    function  get_domImplementation: IDomImplementation;
    function  get_documentElement: IDomElement;
    function  createElement(const tagName: DomString): IDomElement;
    function  createDocumentFragment: IDomDocumentFragment;
    function  createTextNode(const data: DomString): IDomText;
    function  createComment(const data: DomString): IDomComment;
    function  createCDATASection(const data: DomString): IDomCDataSection;
    function  createProcessingInstruction(const target, data: DomString): IDomProcessingInstruction;
    function  createAttribute(const name: DomString): IDomAttr;
    function  createEntityReference(const name: DomString): IDomEntityReference;
    function  getElementsByTagName(const tagName: DomString): IDomNodeList;
    function  importNode(importedNode: IDomNode; deep: Boolean): IDomNode;
    function  createElementNS(const namespaceURI, qualifiedName: DomString): IDomElement;
    function  createAttributeNS(const namespaceURI, qualifiedName: DomString): IDomAttr;
    function  getElementsByTagNameNS(const namespaceURI, localName: DomString): IDomNodeList;
    function  getElementById(const elementId: DomString): IDomElement;
  protected //IDomParseOptions
    function  get_async: Boolean;
    function  get_preserveWhiteSpace: Boolean;
    function  get_resolveExternals: Boolean;
    function  get_validate: Boolean;
    procedure set_async(Value: Boolean);
    procedure set_preserveWhiteSpace(Value: Boolean);
    procedure set_resolveExternals(Value: Boolean);
    procedure set_validate(Value: Boolean);
  protected //IDomPersist
    function  get_xml: DomString;
    function  asyncLoadState: Integer;
    function  load(source: OleVariant): Boolean;
    function  loadFromStream(const stream: TStream): Boolean;
    function  loadxml(const Value: DomString): Boolean;
    procedure save(destination: OleVariant);
    procedure saveToStream(const stream: TStream);
    procedure set_OnAsyncLoad(const Sender: TObject; EventHandler: TAsyncEventHandler);
  protected //
    constructor Create(aLibXml2Node: pointer); override;
    function  requestDocPtr: xmlDocPtr;
    function  requestNodePtr: xmlNodePtr; override;
    function  GetGDoc: xmlDocPtr;
    procedure SetGDoc(aNewDoc: xmlDocPtr);
    function  GetFlyingNodes: TList;
    property  GDoc: xmlDocPtr read GetGDoc write SetGDoc;
    property  DomImplementation: IDomImplementation read get_domImplementation write FGDOMImpl; // internal mean to 'setup' implementation
    property  FlyingNodes: TList read GetFlyingNodes;
  public
    destructor Destroy; override;
  end;

  { TGDOMDocumentFragment }

  TGDOMDocumentFragment = class(TGDOMNode, IDomNode, IDomDocumentFragment)
  protected //IDomNode
    function  IDomNode.get_parentNode = returnNullDomNode;
  end;

  { TGDOMDocumentBuilderFactory }

  TGDOMDocumentBuilderFactory = class(TInterfacedObject, IDomDocumentBuilderFactory)
  private
    FFreeThreading : Boolean;
  protected //IDomDocumentBuilderFactory
    function  NewDocumentBuilder : IDomDocumentBuilder;
    function  Get_VendorID : DomString;
  protected
    constructor Create(AFreeThreading : Boolean);
  end;

  { TGDOMDocumentBuilder }

  TGDOMDocumentBuilder = class(TGDOMObject, IDomDocumentBuilder)
  private
    FFreeThreading : Boolean;
  protected //IDomDocumentBuilder
    function  Get_DomImplementation : IDomImplementation;
    function  Get_IsNamespaceAware : Boolean;
    function  Get_IsValidating : Boolean;
    function  Get_HasAsyncSupport : Boolean;
    function  Get_HasAbsoluteURLSupport : Boolean;
    function  newDocument : IDomDocument;
    function  parse(const xml : DomString) : IDomDocument;
    function  load(const url : DomString) : IDomDocument;
  protected
    constructor Create(AFreeThreading : Boolean);
  public
    destructor Destroy; override;
  end;

var
  doccount: integer=0;
  domcount: integer=0;
  nodecount: integer=0;
  elementcount: integer=0;

implementation

resourcestring
  SNodeExpected = 'Node cannot be null';
  SGDOMNotInstalled = 'GDOME2 is not installed';

const
  DEFAULT_IMPL_FREE_THREADED = false;
var
  GDOMImplementation: array[boolean] of IDomImplementation = (nil, nil);

function ErrorString(err:integer):String;
begin
  case err of
    INDEX_SIZE_ERR: Result:='INDEX_SIZE_ERR';
    DOMSTRING_SIZE_ERR: Result:='DOMSTRING_SIZE_ERR';
    HIERARCHY_REQUEST_ERR: Result:='HIERARCHY_REQUEST_ERR';
    WRONG_DOCUMENT_ERR: Result:='WRONG_DOCUMENT_ERR';
    INVALID_CHARACTER_ERR: Result:='INVALID_CHARACTER_ERR';
    NO_DATA_ALLOWED_ERR: Result:='NO_DATA_ALLOWED_ERR';
    NO_MODIFICATION_ALLOWED_ERR: Result:='NO_MODIFICATION_ALLOWED_ERR';
    NOT_FOUND_ERR: Result:='NOT_FOUND_ERR';
    NOT_SUPPORTED_ERR: Result:='NOT_SUPPORTED_ERR';
    INUSE_ATTRIBUTE_ERR: Result:='INUSE_ATTRIBUTE_ERR';
    INVALID_STATE_ERR: Result:='INVALID_STATE_ERR';
    SYNTAX_ERR: Result:='SYNTAX_ERR';
    INVALID_MODIFICATION_ERR: Result:='INVALID_MODIFICATION_ERR';
    NAMESPACE_ERR: Result:='NAMESPACE_ERR';
    INVALID_ACCESS_ERR: Result:='INVALID_ACCESS_ERR';
    20: Result:='SaveXMLToMemory_ERR';
    21: Result:='NotSupportedByLibxmldom_ERR';
    22: Result:='SaveXMLToDisk_ERR';
    100: Result:='LIBXML2_NULL_POINTER_ERR';
    101: Result:='INVALID_NODE_SET_ERR';
    102: Result:='PARSE_ERR';
  else
    Result:='Unknown error no: '+inttostr(err);
  end;
end;

(**
 * Checks if the condition is true, and raises specified exception if not.
 *)
procedure DomAssert1(aCondition: boolean; aErrorCode:integer; aMsg: WideString; aLocation: String);
begin
  if aErrorCode=0 then exit;
  if aCondition then exit;
  if aMsg='' then begin
    aMsg := ErrorString(aErrorCode);
  end;
  if (aLocation<>'') then begin
    aMsg := 'in class '+aLocation+': '+aMsg;
  end;
  raise EDOMException.Create(aMsg);
end;

function GetDomObject(aNode: pointer): IUnknown;
const
  NodeClasses: array[XML_ELEMENT_NODE..XML_NOTATION_NODE] of TGDOMNodeClass = (
    TGDOMElement,
    TGDOMAttr,
    TGDOMText,
    TGDOMCDataSection,
    TGDOMEntityReference,
    TGDOMEntity,
    TGDOMProcessingInstruction,
    TGDOMComment,
    TGDOMDocument,
    TGDOMDocumentType,
    TGDOMDocumentFragment,
    TGDOMNotation
  );
var
  obj: TGDOMNode;
  node: xmlNodePtr;
  ok: boolean;
begin
  if aNode <> nil then begin
    node := xmlNodePtr(aNode);
    if (node._private=nil) then begin
      ok := (node.type_ >= Low(NodeClasses))
        and (node.type_ <= High(NodeClasses))
        and Assigned(NodeClasses[node.type_]);
      DomAssert1(ok, INVALID_ACCESS_ERR, Format('LibXml2 node type "%d" is not supported', [node.type_]), 'GetDomObject()');
      obj := NodeClasses[node.type_].Create(node); // this assigns node._private
      // notify the node that it has a wrapper already
    end else begin
      // wrapper is already created, use it
      // first check if there is not a garbage
      ok := (node.type_ >= Low(XML_ELEMENT_NODE))
        and (node.type_ <= High(XML_DOCB_DOCUMENT_NODE))
        and Assigned(NodeClasses[node.type_]);
      DomAssert1(ok, INVALID_ACCESS_ERR, 'not a DOM wrapper', 'GetDomObject()');
      obj := node._private;
    end;
  end else begin
    obj := nil;
  end;
  Result := obj;
end;

function GetGNode(const aNode: IDomNode): xmlNodePtr;
begin
  DomAssert1(Assigned(aNode), INVALID_ACCESS_ERR, SNodeExpected, 'GetGNode()');
  Result := (aNode as ILibXml2Node).LibXml2NodePtr;
end;

function IsReadOnlyNode(node:xmlNodePtr): boolean;
begin
  if node<>nil
    then  case node.type_ of
      XML_NOTATION_NODE,XML_ENTITY_NODE,XML_ENTITY_DECL: Result:=true;
    else
      Result:=false;
    end
  else
    Result:=false;
end;

function canAppendNode(priv,newPriv:xmlNodePtr): boolean;
//var
//	new_type: integer;
begin
//ToDo:
//Finish the translation from C
//	if newPriv<>nil
//		then new_type:=newPriv.type_;
  Result:=true;
end;

function prefix(qualifiedName:String):String;
begin
  Result := Copy(qualifiedName,1,Pos(':',qualifiedName)-1);
end;

function localName(qualifiedName:String):String;
var prefix: String;
begin
  prefix := Copy(qualifiedName,1,Pos(':',qualifiedName)-1);
  if length(prefix)>0
    then Result:=(Copy(qualifiedName,Pos(':',qualifiedName)+1,
      length(qualifiedName)-length(prefix)-1))
    else Result:=qualifiedName;
end;

(**
 * Registers a flying node in its document node's wrapper.
 * If the node is already registered, does nothing.
 * Nodes of type that cannot be registered are silently ignored.
 * This is called from TGDOMNode.Create when parent is nil.
 *)
procedure RegisterFlyingNode(aNode: xmlNodePtr);
var
  doc: TGDOMDocument;
begin
  DomAssert1(aNode<>nil, INVALID_ACCESS_ERR, '', 'RegisterFlyingNode()');
  DomAssert1(aNode.parent=nil, INVALID_STATE_ERR, 'Node has a parent, cannot be registered as flying', 'RegisterFlyingNode()');
  case aNode.type_ of
  XML_HTML_DOCUMENT_NODE,
  XML_DOCB_DOCUMENT_NODE,
  XML_DOCUMENT_NODE:
    ; //silently ignore
  else
    GetDOMObject(aNode.doc);  //temporary - ensure that the document's wrapper exists (though it should be almost unneccessary)
    doc := aNode.doc._private; //get the class internal interface
    if doc.FlyingNodes.IndexOf(aNode)<0 then begin
      doc.FlyingNodes.Add(aNode);
    end;
  end;
end;

(**
 * Unregisters the node from the owner document's wrapper.
 * Does not check if parent is already assigned.
 * Nothing happens if the node is not present in the registry.
 *)
procedure UnregisterFlyingNode(aNode: xmlNodePtr);
var
  doc: TGDOMDocument;
  idx: integer;
begin
  GetDOMObject(aNode.doc);  //temporary - ensure that the document's wrapper exists (though it should be almost unneccessary)
  doc := aNode.doc._private; //get the class internal interface
  idx := doc.FlyingNodes.IndexOf(aNode);
  if (idx>0) then begin
    doc.FlyingNodes.Delete(idx);
  end;
end;

(**
 * [ This function will later be submitted in C to xml@gnome.org
 *   Note that order-preserving implementation will have to be posted.
 *   ]
 * Sets an existing attribute node into an element property list.
 * Returns the previous attribute or NULL.
 *)
function xmlSetPropNode(elem: xmlNodePtr; attr: xmlAttrPtr): xmlAttrPtr;
begin
  if (attr.ns=nil) then begin
    Result := xmlHasProp(elem, attr.name);
  end else begin
    Result := xmlHasNsProp(elem, attr.name, attr.ns.href);
  end;
  if (Result<>nil) then begin
    xmlUnlinkNode(xmlNodePtr(Result));
  end;
  xmlAddChild(elem, xmlNodePtr(attr));
  elem.nsDef := attr.ns; //DIRTY  
end;

{ TGDomDocumentBuilderFactory }

constructor TGDOMDocumentBuilderFactory.Create(AFreeThreading : Boolean);
begin
  FFreeThreading := AFreeThreading;
end;

function TGDOMDocumentBuilderFactory.NewDocumentBuilder : IDomDocumentBuilder;
begin
  Result := TGDOMDocumentBuilder.Create(FFreeThreading);
end;

function TGDOMDocumentBuilderFactory.Get_VendorID : DomString;
begin
  if FFreeThreading then
    Result := SLIBXML
  else
    Result := SLIBXML;
end;

{ TXDomDocumentBuilder }

constructor TGDOMDocumentBuilder.Create(AFreeThreading : Boolean);
begin
  inherited Create;
  FFreeThreading := AFreeThreading;
end;

destructor TGDOMDocumentBuilder.Destroy;
begin
  inherited Destroy;
end;

function TGDOMDocumentBuilder.Get_DomImplementation : IDomImplementation;
begin
  Result := TGDOMImplementation.getInstance(FFreeThreading);
end;

function TGDOMDocumentBuilder.Get_IsNamespaceAware : Boolean;
begin
  Result := True;
end;

function TGDOMDocumentBuilder.Get_IsValidating : Boolean;
begin
  Result := True;
end;

function TGDOMDocumentBuilder.Get_HasAbsoluteURLSupport : Boolean;
begin
  Result := False;
end;

function TGDOMDocumentBuilder.Get_HasAsyncSupport : Boolean;
begin
  Result := False;
end;

function TGDOMDocumentBuilder.load(const url: DomString): IDomDocument;
var
  doc: TGDOMDocument;
  ok: boolean;
begin
  doc := TGDOMDocument.Create(nil);
  doc.DomImplementation := Get_DomImplementation;
  ok := doc.load(url);
  DomAssert(ok, PARSE_ERR, 'Error while parsing file:'+url);
  Result := doc;
end;

function TGDOMDocumentBuilder.newDocument: IDomDocument;
var
  doc: TGDOMDocument;
begin
  doc := TGDOMDocument.Create(nil);
  doc.DomImplementation := Get_DomImplementation;
  Result := doc;
end;

function TGDOMDocumentBuilder.parse(const xml: DomString): IDomDocument;
var
  doc: TGDOMDocument;
  ok: boolean;
begin
  doc := TGDOMDocument.Create(nil);
  doc.DomImplementation := Get_DomImplementation;
  ok := doc.loadxml(xml);
  DomAssert(ok, PARSE_ERR, 'Error while parsing xml:'#13+xml);
  Result := doc;
end;

{ TGDOMObject }

procedure TGDOMObject.DomAssert(aCondition: boolean; aErrorCode: integer; aMsg: WideString);
begin
  DomAssert1(aCondition, aErrorCode, aMsg, ClassName);
end;

function TGDOMObject.SafeCallException(ExceptObject: TObject; ExceptAddr: Pointer): HRESULT;
begin
  Result := 0; //todo
end;

{ TGDOMImplementation }

class function TGDOMImplementation.getInstance(aFreeThreading: boolean): IDomImplementation;
begin
  Result := GDOMImplementation[aFreeThreading];
  if (Result = nil) then begin
    Result := TGDOMImplementation.Create; // currently, the same imlementation for both cases
    GDOMImplementation[aFreeThreading] := Result;
  end;
end;

function TGDOMImplementation.hasFeature(const feature, version: DomString): Boolean;
begin
  if (uppercase(feature) ='CORE') and (version = '2.0')
    then Result:=true
    else Result:=false;
end;

function TGDOMImplementation.createDocumentType(const qualifiedName, publicId, systemId: DomString): IDomDocumentType;
var
  dtd:xmlDtdPtr;
  uqname, upubid, usysid: String;
begin
  uqname := UTF8Encode(qualifiedName);
  upubid := UTF8Encode(publicId);
  usysid := UTF8Encode(systemId);
  dtd := xmlCreateIntSubSet(nil, PChar(uqname), PChar(upubid), PChar(usysid)); //todo: doc!
  Result := GetDomObject(dtd) as IDomDocumentType;
end;

function TGDOMImplementation.createDocument(const namespaceURI, qualifiedName: DomString; doctype: IDomDocumentType): IDomDocument;
begin
  DomAssert(doctype=nil, NOT_SUPPORTED_ERR, 'TGDOMDocument.create with doctype not implemented yet');
  Result := TGDOMDocument.Create(nil);
  // prepare documentElement if necessary
  if (qualifiedName<>'') then begin
    Result.appendChild(Result.createElementNS(namespaceURI, qualifiedName));
  end;
end;

{ TGDomeNode }

constructor TGDOMNode.Create(aLibXml2Node: pointer);
begin
  inherited Create;
  FGNode := aLibXml2Node;
  if not (self is TGDOMDocument) then begin
    // this node is not a document
    DomAssert(Assigned(aLibXml2Node), INVALID_ACCESS_ERR, 'TGDOMNode.Create: Cannot wrap null node');
    FGNode._private := self;
    DomAssert(FGNode.doc<>nil, INVALID_ACCESS_ERR, 'TGDOMNode.Create: Cannot wrap node not attached to any document');
    // if the node is flying, register it in the owner document
    if (FGNode.parent=nil) then begin
      RegisterFlyingNode(FGNode);
    end;
    // if this is not the document itself, pretend having a reference to the owner document.
    // This ensures that the document lives exactly as long as any wrapper node (created by this doc) exists
		get_ownerDocument._AddRef;
  end;
  Inc(nodecount);
end;

destructor TGDOMNode.Destroy;
begin
  if not (self is TGDOMDocument) then begin
  // if this is not the document itself, release the pretended reference to the owner document:
  // This ensures that the document lives exactly as long as any wrapper node (created by this doc) exists
		get_ownerDocument._Release;
  end;
  if (FGNode<>nil) then begin
    FGNode._private := nil;
  end;
  FChildNodes.Free;
  Dec(nodecount);
  inherited Destroy;
end;

function TGDOMNode.LibXml2NodePtr: xmlNodePtr;
begin
  Result := FGNode;
end;

(**
 * This function implements null return value for all the traversal functions
 * where null is required by DOM spec. in Attr interface
 *)
function TGDOMNode.returnNullDomNode: IDomNode;
begin
  Result := nil;
end;

function TGDOMNode.returnEmptyString: DomString;
begin
  Result := '';
end;

function TGDOMNode.get_nodeName: DomString;
begin
  case FGNode.type_ of
  XML_HTML_DOCUMENT_NODE,
  XML_DOCB_DOCUMENT_NODE,
  XML_DOCUMENT_NODE:
    Result := '#document';
  XML_TEXT_NODE,
  XML_CDATA_SECTION_NODE,
  XML_COMMENT_NODE,
  XML_DOCUMENT_FRAG_NODE:
    Result := '#'+UTF8Decode(FGNode.name);
  else
    Result := UTF8Decode(FGNode.name);
    if (FGNode.ns<>nil) and (FGNode.ns.prefix<>nil) then begin
      Result := UTF8Decode(FGNode.ns.prefix)+':'+Result;
    end;
  end;
end;

function TGDOMNode.get_nodeValue: DomString;
var
  p: PxmlChar;
begin
  case FGNode.type_ of
  XML_ATTRIBUTE_NODE,
  XML_TEXT_NODE,
  XML_CDATA_SECTION_NODE,
  XML_ENTITY_REF_NODE,
  XML_COMMENT_NODE,
  XML_PI_NODE:
    begin
      p := xmlNodeGetContent(FGNode);
      if (p<>nil) then begin
        Result := UTF8Decode(p);
        xmlFree(p);
      end;
    end;
  else
    Result := '';
  end;
end;

procedure TGDOMNode.set_nodeValue(const value: DomString);
begin
  case FGNode.type_ of
  XML_ATTRIBUTE_NODE,
  XML_TEXT_NODE,
  XML_CDATA_SECTION_NODE,
  XML_ENTITY_REF_NODE,
  XML_COMMENT_NODE,
  XML_PI_NODE:
    begin
      xmlNodeSetContent(FGNode, PChar(UTF8Encode(value)));
    end;
  else
    DomAssert(false, NO_MODIFICATION_ALLOWED_ERR);
  end;
end;

function TGDOMNode.get_nodeType: DOMNodeType;
begin
  Result := domNodeType(FGNode.type_);
end;

function TGDOMNode.get_parentNode: IDomNode;
begin
  Result := GetDOMObject(FGNode.parent) as IDomNode
end;

function TGDOMNode.get_childNodes: IDomNodeList;
begin
  if (FChildNodes=nil) then begin
    // create wrapper for child list, if relevant
    case get_nodeType of
    DOCUMENT_NODE,
    ELEMENT_NODE:
      TGDOMChildNodeList.Create(self); // assigns FChildNodes
    end;
  end;
  Result := FChildNodes;
end;

function TGDOMNode.get_firstChild: IDomNode;
begin
  if FGNode=nil then begin
    Result := nil;
  end else begin
    Result := GetDOMObject(FGNode.children) as IDomNode;
  end;
end;

function TGDOMNode.get_lastChild: IDomNode;
begin
  if FGNode=nil then begin
    Result := nil;
  end else begin
    Result := GetDOMObject(FGNode.last) as IDomNode;
  end;
end;

function TGDOMNode.get_previousSibling: IDomNode;
begin
  Result := GetDOMObject(FGNode.prev) as IDomNode;
end;

function TGDOMNode.get_nextSibling: IDomNode;
begin
  Result := GetDOMObject(FGNode.next) as IDomNode;
end;

function TGDOMNode.get_attributes: IDomNamedNodeMap;
begin
  Result := nil;
end;

function TGDOMNode.get_ownerDocument: IDomDocument;
begin
  if FGNode=nil then begin
    Result := nil;
  end else begin
    Result := GetDOMObject(FGNode.doc) as IDomDocument;
  end;
end;

function TGDOMNode.get_namespaceURI: DomString;
begin
  case FGNode.type_ of
  XML_ELEMENT_NODE,
  XML_ATTRIBUTE_NODE:
    begin
      if FGNode.ns=nil then exit;
      Result := UTF8Decode(FGNode.ns.href);
    end;
  else
    Result := '';
  end;
end;

function TGDOMNode.get_prefix: DomString;
begin
  case FGNode.type_ of
  XML_ELEMENT_NODE,
  XML_ATTRIBUTE_NODE:
    begin
      if FGNode.ns=nil then exit;
      Result := UTF8Decode(FGNode.ns.prefix);
    end;
  end;
end;

function TGDOMNode.get_localName: DomString;
begin
  case FGNode.type_ of
  XML_ELEMENT_NODE,
  XML_ATTRIBUTE_NODE:
    // this is neccessary, because according to the dom2
    // specification localName has to be nil for nodes,
    // that don't have a namespace
    Result := UTF8Decode(FGNode.name);
  else
    Result := '';
  end;
end;

procedure TGDOMNode.RegisterNS(const prefix, URI: DomString);
begin
//todo
end;

function TGDOMNode.IsReadOnly: boolean;
begin
  Result:=IsReadOnlyNode(FGNode)
end;

function TGDOMNode.IsAncestorOrSelf(newNode: xmlNodePtr): boolean;
var
  node:xmlNodePtr;
begin
  node:=FGNode;
  Result:=true;
  while node<>nil do begin
    if node=newNode
      then exit;
    node:=node.parent;
  end;
  Result:=false;
end;

function TGDOMNode.requestNodePtr: xmlNodePtr;
begin
  DomAssert(FGNode<>nil, INVALID_ACCESS_ERR, ClassName+'.requestNodePtr: wrapping null node');
  Result := FGNode;
end;

function TGDOMNode.insertBefore(const newChild, refChild: IDomNode): IDomNode;
var
  node: xmlNodePtr;
  child: xmlNodePtr;
const
  CHILD_TYPES = [
    Element_Node,
    Text_Node,
    CDATA_Section_Node,
    Entity_Reference_Node,
    Processing_Instruction_Node,
    Comment_Node,
    Document_Type_Node,
    Document_Fragment_Node,
    Notation_Node
  ];
begin
  DomAssert(newChild<>nil, INVALID_ACCESS_ERR, 'TGDOMNode.insertBefore: cannot append null');
  DomAssert(not IsReadOnly, NO_MODIFICATION_ALLOWED_ERR);
  DomAssert((newChild.nodeType in CHILD_TYPES), HIERARCHY_REQUEST_ERR, 'TGDOMNode.insertBefore: newChild cannot be inserted, nodetype = '+IntToStr(get_nodeType));

  if (requestNodePtr.type_=XML_DOCUMENT_NODE) and (newChild.nodeType = ELEMENT_NODE) then begin
    DomAssert((xmlDocGetRootElement(xmlDocPtr(FGNode))=nil), HIERARCHY_REQUEST_ERR, 'TGDOMNode.insertBefore: document already has a documentElement');
  end;

  child := GetGNode(newChild);
  DomAssert(not IsAncestorOrSelf(child), HIERARCHY_REQUEST_ERR);
  DomAssert(child.doc=FGNode.doc, WRONG_DOCUMENT_ERR, 'TGDOMNode.insertBefore: cannot insert a node from other document');
  DomAssert(not IsReadOnlyNode(child.parent), NO_MODIFICATION_ALLOWED_ERR, 'TGDOMNode.insertBefore: modification not allowed here');

  UnregisterFlyingNode(child);
  if (refChild=nil) then begin
    xmlUnlinkNode(child);
    node := xmlAddChild(FGNode, child);
  end else begin
    node := xmlAddPrevSibling(GetGNode(refChild), child);
  end;
  Result := GetDOMObject(node) as IDomNode;
end;

function TGDOMNode.replaceChild(const newChild, oldChild: IDomNode): IDomNode;
var
  old, cur, node: xmlNodePtr;
begin
  DomAssert(oldChild<>nil, INVALID_CHARACTER_ERR, 'TGDOMNode.replaceChild: oldChild is null');
  DomAssert(newChild<>nil, INVALID_CHARACTER_ERR, 'TGDOMNode.replaceChild: newChild is null');
  old := GetGNode(oldChild);
  cur := GetGNode(newChild);
  node := xmlReplaceNode(old, cur);
  RegisterFlyingNode(old);
  UnregisterFlyingNode(cur);
  Result := GetDOMObject(node) as IDomNode
end;

function TGDOMNode.removeChild(const childNode: IDomNode): IDomNode;
var
  child: xmlNodePtr;
begin
  DomAssert(childNode<>nil, INVALID_CHARACTER_ERR, 'TGDOMNode.removeChild: childNode is null');
  child := GetGNode(childNode);
  xmlUnlinkNode(child);
  RegisterFlyingNode(child);
  Result := childNode;
end;

(**
 * Appends a node at the end of childlist.
 * @newChild:  The node to add
 *
 * Returns: the node added.
 *)
function TGDOMNode.appendChild(const newChild: IDomNode): IDomNode;
begin
  Result := insertBefore(newChild, nil);
end;

function TGDOMNode.hasChildNodes: Boolean;
begin
  Result := False;
  if FGNode=nil then exit;
  if FGNode.children=nil then exit;
  Result := True;
end;

function TGDOMNode.hasAttributes: Boolean;
begin
  Result := False;
end;

function TGDOMNode.cloneNode(deep: Boolean): IDomNode;
var
  node: xmlNodePtr;
  recursive: Integer;
begin
  if deep
  then recursive:= 1
  else recursive:= 0;
  node := xmlCopyNode(requestNodePtr, recursive);
  Result := GetDOMObject(node) as IDomNode;
end;

procedure TGDOMNode.normalize;
var
  node,next,new_next: xmlNodePtr;
  nodeType: integer;
begin
  node:=FGNode.children;
  next:=nil;
  while node<>nil do begin
    nodeType:=node.type_;
    if nodeType=TEXT_NODE then begin
      next:=node.next;
      while next<>nil do begin
        if next.type_<>TEXT_NODE then break;
        xmlTextConcat(node,next.content,length(next.content));
        new_next:=next.next;
        xmlUnlinkNode(next);
        xmlFreeNode(next); //carefull!!
        next:=new_next;
      end;
    end else if nodeType=ELEMENT_NODE then begin
      //todo
    end;
    node:=next;
  end;
end;

function TGDOMNode.isSupported(const feature, version: DomString): Boolean;
begin
  if (((upperCase(feature)='CORE') and (version='2.0')) or
     (upperCase(feature)='XML')  and (version='2.0')) //[pk] ??? what ???
    then Result:=true
  else Result:=false;
end;

function TGDOMNode.selectNode(const nodePath: WideString): IDomNode;
// todo: raise  exceptions
//       a) if invalid nodePath expression
//       b) if Result type <> nodelist
var
	ctxt: xmlXPathContextPtr;
	rv: xmlXPathObjectPtr;
	node: xmlNodePtr;
begin
	ctxt := xmlXPathNewContext(GNode.doc);
	rv := xmlXPathEval(PChar(UTF8Encode(nodePath)), ctxt);
	Result := nil;
	if (rv=nil) then exit;
	if (rv.type_ = XPATH_NODESET) then begin
		if (rv.nodesetval.nodeNr > 0) then begin
			node := rv.nodesetval.nodeTab^;
			Result := GetDomObject(node) as IDomNode;
		end;
	end;
	xmlXPathFreeObject(rv);
end;

function TGDOMNode.selectNodes(const nodePath: WideString): IDomNodeList;
begin
  Result := TGDOMXPathNodeList.Create(self, nodePath);
end;

procedure TGDOMNode.set_Prefix(const prefix: DomString);
begin
  DomAssert(false, NOT_SUPPORTED_ERR);
end;

{ TGDOMChildNodeList }

constructor TGDOMChildNodeList.Create(aOwnerNode: TGDOMNode);
begin
  inherited Create;
  DomAssert(aOwnerNode<>nil, HIERARCHY_REQUEST_ERR, 'Child list must have a parent');
  FOwnerNode := aOwnerNode;
  FOwnerNode.FChildNodes := self;
end;

destructor TGDOMChildNodeList.Destroy;
begin
  FOwnerNode.FChildNodes := nil;
  FOwnerNode := nil;
  inherited Destroy;
end;

function TGDOMChildNodeList.get_item(index: Integer): IDomNode;
var
  node: xmlNodePtr;
  cnt: integer;
begin
  DomAssert(index>=0, INDEX_SIZE_ERR);
  node := FOwnerNode.requestNodePtr.children;
  cnt := 0;
  while (cnt<index) do begin
    if (node=nil) then begin
      DomAssert(false, INDEX_SIZE_ERR, Format('Trying to access item %d [zero based] of %d items', [index, cnt]));
    end;
    Inc(cnt);
    node := node.next;
  end;
  Result := GetDOMObject(node) as IDomNode;
end;

function TGDOMChildNodeList.get_length: Integer;
var
  node: xmlNodePtr;
begin
  Result := 0;
  node := FOwnerNode.GNode.children;
  while (node<>nil) do begin
    Inc(Result);
    node := node.next;
  end;
end;

{ TGDOMXPathNodeList }

constructor TGDOMXPathNodeList.Create(aBaseNode: TGDOMNode; aQuery: String);
begin
  inherited Create;
  DomAssert(aBaseNode<>nil, HIERARCHY_REQUEST_ERR, 'XPath query must have a parent');
  FXPathCtxt := xmlXPathNewContext(aBaseNode.Gnode.doc);
  Eval;
end;

destructor TGDOMXPathNodeList.Destroy;
begin
	if (FXPathObj<>nil) then begin
    xmlXPathFreeObject(FXPathObj);
  end;
  xmlXPathFreeContext(FXPathCtxt);
  inherited;
end;

(**
 * This function re-evaluates the query against the base node.
 * The purpose of having it is, to achieve DOM requirement that
 * all nodelists are 'live'. Later (but very soon) we should call it in get_item
 * and get_length whenever any tree change is detected after the last call. [pk]
 *)
procedure TGDOMXPathNodeList.Eval;
begin
	if (FXPathObj<>nil) then begin
    xmlXPathFreeObject(FXPathObj);
  end;
  FXPathObj := xmlXPathEvalExpression(PChar(FQuery), FXPathCtxt);
  DomAssert(FXPathObj<>nil, INVALID_ACCESS_ERR, 'XPath object does not exist');
  if (FXPathObj.type_ <> XPATH_NODESET) then begin
    DomAssert(false, INVALID_ACCESS_ERR, 'XPath object is not a nodeset');
    xmlXPathFreeObject(FXPathObj);
    FXPathObj := nil;
  end;
end;

function TGDOMXPathNodeList.get_item(index: Integer): IDomNode;
begin
  DomAssert(index<0, INVALID_ACCESS_ERR, 'Index below zero');
  DomAssert(index>=FXPathObj.nodesetval.nodeNr, INVALID_ACCESS_ERR, 'Index too high');
  Result := GetDomObject(xmlXPathNodeSetItem(FXPathObj.nodesetval, index)) as IDomNode;
end;

function TGDOMXPathNodeList.get_length: Integer;
begin
  Result := xmlXPathNodeSetGetLength(FXPathObj.nodesetval);
end;

{ TGDOMAttributes }

constructor TGDOMAttributes.Create(aOwnerElement: TGDOMElement);
begin
  inherited Create;
  DomAssert(aOwnerElement<>nil, HIERARCHY_REQUEST_ERR, 'Attribute list must have an owner element');
  FOwnerElement := aOwnerElement;
  FOwnerElement.FAttributes := self;
end;

destructor TGDOMAttributes.Destroy;
begin
  FOwnerElement.FAttributes := nil;
  FOwnerElement := nil;
  inherited destroy;
end;

function TGDOMAttributes.get_item(index: Integer): IDomNode;
var
  node: xmlAttrPtr;
  cnt: integer;
begin
  DomAssert(index>=0, INDEX_SIZE_ERR);
  node := FOwnerElement.requestNodePtr.properties;
  cnt := 0;
  while (cnt<index) do begin
    if (node=nil) then begin
      DomAssert(false, INDEX_SIZE_ERR, Format('Trying to access item %d [zero based] of %d items', [index, cnt]));
    end;
    Inc(cnt);
    node := node.next;
  end;
  Result := GetDOMObject(node) as IDomNode;
end;

function TGDOMAttributes.get_length: Integer;
var
  node: xmlAttrPtr;
begin
  Result := 0;
  node := FOwnerElement.GNode.properties;
  while (node<>nil) do begin
    Inc(Result);
    node := node.next;
  end;
end;

function TGDOMAttributes.getNamedItem(const name: DomString): IDomNode;
begin
  Result := FOwnerElement.getAttributeNode(name);
end;

function TGDOMAttributes.setNamedItem(const newItem: IDomNode): IDomNode;
begin
  Result := FOwnerElement.setAttributeNodeNS(newItem as IDomAttr);
end;

function TGDOMAttributes.removeNamedItem(const name: DomString): IDomNode;
begin
  Result := FOwnerElement.removeAttributeNode(FOwnerElement.getAttributeNode(name) as IDomAttr);
end;

function TGDOMAttributes.getNamedItemNS(const namespaceURI, localName: DomString): IDomNode;
begin
  Result := FOwnerElement.getAttributeNodeNS(namespaceURI, localName);
end;

function TGDOMAttributes.setNamedItemNS(const newItem: IDomNode): IDomNode;
begin
  Result := FOwnerElement.setAttributeNodeNS(newItem as IDomAttr);
end;

function TGDOMAttributes.removeNamedItemNS(const namespaceURI, localName: DomString): IDomNode;
begin
  Result := FOwnerElement.removeAttributeNode(FOwnerElement.getAttributeNodeNS(namespaceURI, localName) as IDomAttr);
end;

{ TGDOMAttr }

function TGDOMAttr.get_ownerElement: IDomElement;
begin
  Result := GetDOMObject(FGNode.parent) as IDomElement;
end;

function TGDOMAttr.get_specified: Boolean;
begin
  //todo: implement it correctly
  Result:=true;
end;

{
procedure TGDOMAttr.set_nodeValue(const value: DomString);
var
  attr: xmlAttrPtr;
  tmp: xmlNodePtr;
  v: String;
begin
  v := UTF8Encode(value);
  attr := xmlAttrPtr(FGNode);
  if attr.children<>nil then begin
    xmlFreeNodeList(attr.children);
    attr.children:=nil;
    attr.last:=nil;
  end;
  attr.children := xmlStringGetNodeList(attr.doc, PChar(v));
  tmp := attr.children;
  while tmp<>nil do begin
    tmp.parent := xmlNodePtr(attr);
    tmp.doc := attr.doc;
    if tmp.next=nil then begin
      attr.last := tmp;
    end;
    tmp := tmp.next;
  end;
end;
}

{ TGDOMElement }

function TGDOMElement.getAttribute(const name: DomString): DomString;
var
  p: PxmlChar;
begin
  //todo: handle prefixed case
  p := xmlGetProp(FGNode,PChar(UTF8Encode(name)));
  Result := UTF8Decode(p);
  xmlFree(p);
end;

function TGDOMElement.get_attributes: IDomNamedNodeMap;
begin
  if (FAttributes=nil) then begin
    TGDOMAttributes.Create(self); // assigns FAttributes
  end;
  Result := FAttributes;
end;

procedure TGDOMElement.setAttribute(const name, value: DomString);
begin
  xmlSetProp(FGNode, PChar(UTF8Encode(name)), PChar(UTF8Encode(value)));
end;

procedure TGDOMElement.removeAttribute(const name: DomString);
var
  attr: xmlAttrPtr;
begin
  attr := xmlHasProp(FGNode, PChar(UTF8Encode(name)));
  if attr <> nil then begin
    xmlUnlinkNode(xmlNodePtr(attr));
    RegisterFlyingNode(xmlNodePtr(attr));
  end;
end;

function TGDOMElement.getAttributeNode(const name: DomString): IDomAttr;
var
  attr: xmlAttrPtr;
begin
  attr := xmlHasProp(FGNode, PChar(UTF8Encode(name)));
  Result := GetDOMObject(attr) as IDomAttr;
end;

function TGDOMElement.removeAttributeNode(const oldAttr: IDomAttr):IDomAttr;
var
  attr: xmlAttrPtr;
begin
  Result := oldAttr;
  if oldAttr=nil then exit;
  attr := xmlAttrPtr(GetGNode(oldAttr));
  xmlUnlinkNode(xmlNodePtr(attr));
  RegisterFlyingNode(xmlNodePtr(attr));
end;

function TGDOMElement.getElementsByTagName(const name: DomString): IDomNodeList;
begin
  Result:=selectNodes(name);
end;

function TGDOMElement.getAttributeNS(const namespaceURI, localName: DomString): DomString;
var
  p: PxmlChar;
begin
  p := xmlGetNSProp(FGNode, PChar(UTF8Encode(localName)), PChar(UTF8Encode(namespaceURI)));
  Result := UTF8Decode(p);
  xmlFree(p);
end;

procedure TGDOMElement.setAttributeNS(const namespaceURI, qualifiedName, value: DomString);
var
  uprefix, ulocal: String;
  ns: xmlNsPtr;
begin
  uprefix := prefix(qualifiedName);
  ulocal := localName(qualifiedName);
  ns := xmlNewNs(FGNode, PChar(UTF8Encode(namespaceURI)), PChar(uprefix));
  xmlSetNSProp(FGNode, ns, PChar(ulocal), PChar(UTF8Encode(value)));
end;

procedure TGDOMElement.removeAttributeNS(const namespaceURI, localName: DomString);
var
  attr: xmlAttrPtr;
  uns, ulocal: String;
begin
  uns := UTF8Encode(localName);
  ulocal := UTF8Encode(namespaceURI);
  attr := xmlHasNsProp(FGNode, PChar(uns), PChar(ulocal));
  if (attr <> nil) then begin
    xmlUnlinkNode(xmlNodePtr(attr));
    RegisterFlyingNode(xmlNodePtr(attr));
  end;
end;

function TGDOMElement.getAttributeNodeNS(const namespaceURI, localName: DomString): IDomAttr;
var
  attr: xmlAttrPtr;
begin
  attr := xmlHasNSProp(FGNode, PChar(UTF8Encode(localName)), PChar(UTF8Encode(namespaceURI)));
  Result := GetDOMObject(attr) as IDomAttr;
end;

{$define EXPERIMENTAL}
function TGDOMElement.setAttributeNodeNS(const newAttr: IDomAttr): IDomAttr;
var
  attr, newa, olda: xmlAttrPtr;
begin
  if newAttr<>nil then begin
    newa := xmlAttrPtr(GetGNode(newAttr));
{$ifdef EXPERIMENTAL}
    xmlSetPropNode(FGNode, newa);
{$else}
    if (newa.ns=nil) then begin
      olda := xmlHasProp(FGNode, newa.name);
    end else begin
      olda := xmlHasNsProp(FGNode, newa.name, newa.ns.href);
    end;
    if (newa=olda) then begin
      Result := newAttr;
    end else begin
      if (olda<>nil) then begin
        xmlUnlinkNode(xmlNodePtr(olda));
        RegisterFlyingNode(xmlNodePtr(olda));
      end;

      //put it to the front of attrlist (because it is the simplest way)
      attr := FGNode.properties;
      FGNode.properties := newa;
      newa.next := attr;
      newa.parent := FGNode;
      FGNode.nsDef := newa.ns; //[pk] I am not sure if this is really correct, looks strange
      if attr=nil then begin
        FGNode.properties := newa;
      end else begin
        attr.prev := newa;
      end;
      UnregisterFlyingNode(xmlNodePtr(newa));
      Result := GetDomObject(olda) as IDomAttr;
    end;
{$endif}
  end else begin
    Result := nil;
  end;
end;

function TGDOMElement.getElementsByTagNameNS(const namespaceURI, localName: DomString): IDomNodeList;
begin
  //todo: more generic code
  RegisterNs('xyz4ct',namespaceURI);
  Result:=selectNodes('xyz4ct:'+localName);
end;

function TGDOMElement.hasAttribute(const name: DomString): Boolean;
begin
  Result := xmlHasProp(FGNode, PChar(UTF8Encode(name)))<>nil;
end;


function TGDOMElement.hasAttributeNS(const namespaceURI, localName: DomString): Boolean;
begin
  Result := (nil<>xmlHasNsProp(FGNode, PChar(UTF8Encode(localName)), PChar(UTF8Encode(namespaceURI))));
end;

constructor TGDOMElement.Create(aLibXml2Node: pointer);
begin
  inherited Create(aLibXml2Node);
  Inc(elementcount);
end;

destructor TGDOMElement.Destroy;
begin
  Dec(elementcount);
  inherited Destroy;
end;

{ TGDOMDocument }

constructor TGDOMDocument.Create(aLibXml2Node: pointer);
begin
  inherited Create(aLibXml2Node);
  Inc(doccount);
end;

destructor TGDOMDocument.Destroy;
begin
  GDoc := nil;
  Dec(doccount);
  FFlyingNodes.Free;
  FFlyingNodes := nil;
  inherited Destroy;
end;

function TGDOMDocument.get_doctype: IDomDocumentType;
var
  dtd: xmlDtdPtr;
begin
  Result := nil;
  if GDoc=nil then exit;
  dtd := GDoc.intSubset;
  if dtd = nil then exit;
  Result := GetDomObject(dtd) as IDomDocumentType;
end;

function TGDOMDocument.get_domImplementation: IDomImplementation;
begin
  if FGDOMImpl=nil then begin
    FGDOMImpl := TGDOMImplementation.getInstance(DEFAULT_IMPL_FREE_THREADED);
  end;
  Result := FGDOMImpl;
end;

function TGDOMDocument.get_documentElement: IDomElement;
begin
  Result := GetDOMObject(xmlDocGetRootElement(GDoc)) as IDomElement;
end;

function TGDOMDocument.createElement(const tagName: DomString): IDomElement;
var
  node: xmlNodePtr;
begin
  node := xmlNewDocNode(requestDocPtr, nil, PChar(UTF8Encode(tagName)),nil);
  Result := GetDOMObject(node) as IDomElement;
end;

function TGDOMDocument.createDocumentFragment: IDomDocumentFragment;
var
  node: xmlNodePtr;
begin
  node := xmlNewDocFragment(requestDocPtr);
  Result := GetDOMObject(node) as IDomDocumentFragment;
end;

function TGDOMDocument.createTextNode(const data: DomString): IDomText;
var
  node: xmlNodePtr;
begin
  node := xmlNewDocText(requestDocPtr, PChar(UTF8Encode(data)));
  Result := GetDOMObject(node) as IDomText;
end;

function TGDOMDocument.createComment(const data: DomString): IDomComment;
var
  node: xmlNodePtr;
begin
  node := xmlNewDocComment(requestDocPtr, PChar(UTF8Encode(data)));
  Result := GetDOMObject(node) as IDomComment;
end;

function TGDOMDocument.createCDATASection(const data: DomString): IDomCDataSection;
var
  s: String;
  node: xmlNodePtr;
begin
  s := UTF8Encode(data);
  node := xmlNewCDataBlock(requestDocPtr, PChar(s), length(s));
  Result := GetDOMObject(node) as IDomCDataSection;
end;

function TGDOMDocument.createProcessingInstruction(const target, data: DomString): IDomProcessingInstruction;
var
  pi: xmlNodePtr;
begin
  pi := xmlNewPI(PChar(UTF8Encode(target)), PChar(UTF8Encode(data)));
  pi.doc := requestDocPtr;
  Result := GetDOMObject(pi) as IDomProcessingInstruction;
end;

function TGDOMDocument.createAttribute(const name: DomString): IDomAttr;
var
  attr: xmlAttrPtr;
begin
  attr := xmlNewDocProp(requestDocPtr, PChar(UTF8Encode(name)), nil);
  Result := GetDOMObject(attr) as IDomAttr;
end;

function TGDOMDocument.createEntityReference(const name: DomString): IDomEntityReference;
var
  node: xmlNodePtr;
begin
  node := xmlNewReference(requestDocPtr, PChar(UTF8Encode(name)));
  Result := GetDOMObject(node) as IDomEntityReference;
end;

function TGDOMDocument.getElementsByTagName(const tagName: DomString): IDomNodeList;
begin
  //todo: restrict tagName to QNAME production
  //todo: selectNodes must work also directly at docnode
  Result := (get_documentElement as IDomNodeSelect).selectNodes(tagName);
end;

function TGDOMDocument.importNode(importedNode: IDomNode; deep: Boolean): IDomNode;
var
  recurse: integer;
  node: xmlNodePtr;
(**
 * gdome_xml_doc_importNode:
 * @self:  Document Objects ref
 * @importedNode:  The node to import.
 * @deep:  If %TRUE, recursively import the subtree under the specified node;
 *         if %FALSE, import only the node itself. This has no effect on Attr,
 *         EntityReference, and Notation nodes.
 * @exc:  Exception Object ref
 *
 *
 * Imports a node from another document to this document. The returned node has
 * no parent; (parentNode is %NULL). The source node is not altered or removed
 * from the original document; this method creates a new copy of the source
 * node. %GDOME_DOCUMENT_NODE, %GDOME_DOCUMENT_TYPE_NODE, %GDOME_NOTATION_NODE
 * and %GDOME_ENTITY_NODE nodes are not supported.
 *
 * %GDOME_NOT_SUPPORTED_ERR: Raised if the type of node being imported is not
 * supported.
 * Returns: the imported node that belongs to this Document.
 *)
begin
  Result:=nil;
  if importedNode=nil then exit;
  case integer(importedNode.nodeType) of
    DOCUMENT_NODE,
    DOCUMENT_TYPE_NODE,
    NOTATION_NODE,
    ENTITY_NODE:
      DomAssert(false, NOT_SUPPORTED_ERR);
    ATTRIBUTE_NODE:
      DomAssert(false, NOT_SUPPORTED_ERR); //ToDo: implement this case
  else
    if deep
    then recurse:=1
    else recurse:=0;
    node:=xmlDocCopyNode(GetGNode(importedNode), requestDocPtr, recurse);
    Result := GetDOMObject(node) as IDomNode;
  end;
end;
(* the c-code to translate (from gdome)

GdomeNode *
gdome_xml_doc_importNode (GdomeDocument *self, GdomeNode *importedNode, GdomeBoolean deep, GdomeException *exc) {
  Gdome_xml_Document *priv = (Gdome_xml_Document * )self;
  Gdome_xml_Node *priv_node = (Gdome_xml_Node * )importedNode;
  xmlNode *ret = NULL;

  g_return_val_if_fail (priv != NULL, NULL);
  g_return_val_if_fail (GDOME_XML_IS_DOC (priv), NULL);
  g_return_val_if_fail (importedNode != NULL, NULL);
  g_return_val_if_fail (exc != NULL, NULL);

  switch (gdome_xml_n_nodeType (importedNode, exc)) {
  case XML_ATTRIBUTE_NODE:
    g_assert (gdome_xmlGetOwner ((xmlNode * )priv->n) == priv->n);
    ret = (xmlNode * )xmlCopyProp ((xmlNode * )priv->n, (xmlAttr * )priv_node->n);
    gdome_xmlSetParent (ret, NULL);
    break;
  case XML_DOCUMENT_FRAG_NODE:
  case XML_ELEMENT_NODE:
  case XML_ENTITY_REF_NODE:
  case XML_PI_NODE:
  case XML_TEXT_NODE:
  case XML_CDATA_SECTION_NODE:
  case XML_COMMENT_NODE:
    ret = xmlDocCopyNode (priv_node->n, priv->n, deep);
    break;
  default:
    *exc = GDOME_NOT_SUPPORTED_ERR;
  }

  return gdome_xml_n_mkref (ret);
}
*)

function TGDOMDocument.createElementNS(const namespaceURI, qualifiedName: DomString): IDomElement;
var
  node: xmlNodePtr;
  ns: xmlNsPtr;
  uprefix, ulocal: String;
begin
  if (namespaceURI<>'') then begin
    uprefix := prefix(qualifiedName);
    ulocal := localName(qualifiedName);
    node := xmlNewDocNode(requestDocPtr, nil, PChar(ulocal), nil);
    ns := xmlNewNs(node, PChar(UTF8Encode(namespaceURI)), PChar(uprefix));
    xmlSetNs(node, ns);
  end else begin
    ulocal := UTF8Encode(qualifiedName);
    node := xmlNewDocNode(requestDocPtr, nil, PChar(UTF8Encode(qualifiedName)), nil);
  end;
  Result := GetDOMObject(node) as IDomElement;
end;

function TGDOMDocument.createAttributeNS(const namespaceURI, qualifiedName: DomString): IDomAttr;
var
  attr: xmlAttrPtr;
  ns: xmlNsPtr;
  uprefix, ulocal: String;
begin
  if (namespaceURI<>'') then begin
    uprefix := prefix(qualifiedName);
    ulocal := localName(qualifiedName);
    ns := xmlNewNs(nil, PChar(UTF8Encode(namespaceURI)), PChar(uprefix));
    attr := xmlNewNsProp(nil, ns, PChar(ulocal), nil);
    attr.doc := requestDocPtr;
  end else begin
    ulocal := UTF8Encode(qualifiedName);
    attr := xmlNewDocProp(requestDocPtr, PChar(ulocal), nil);
  end;
  Result := GetDOMObject(attr) as IDomAttr;
end;

function TGDOMDocument.getElementsByTagNameNS(const namespaceURI, localName: DomString): IDomNodeList;
var
  docElement: IDomElement;
begin
  docElement := get_documentElement;
  Result := docElement.getElementsByTagNameNS(namespaceURI,localName);
end;

function TGDOMDocument.getElementById(const elementId: DomString): IDomElement;
var
  attr: xmlAttrPtr;
begin
  attr := xmlGetID(requestDocPtr, PChar(UTF8Encode(elementId)));
  if (attr<>nil) then begin
    Result := GetDOMObject(attr.parent) as IDomElement;
  end else begin
    Result := nil;
  end;
end;

function TGDOMDocument.get_async: Boolean;
begin
  Result:=FAsync;
end;

function TGDOMDocument.get_preserveWhiteSpace: Boolean;
begin
  Result:=FPreserveWhiteSpace;
end;

function TGDOMDocument.get_resolveExternals: Boolean;
begin
  Result:=FResolveExternals;
end;

function TGDOMDocument.get_validate: Boolean;
begin
  Result:=FValidate;
end;

procedure TGDOMDocument.set_async(Value: Boolean);
begin
  FAsync:=true;
end;

procedure TGDOMDocument.set_preserveWhiteSpace(Value: Boolean);
begin
  FPreserveWhitespace:=true;
end;

procedure TGDOMDocument.set_resolveExternals(Value: Boolean);
begin
  FResolveExternals:=true;
end;

procedure TGDOMDocument.set_validate(Value: Boolean);
begin
  Fvalidate:=true;
end;

function TGDOMDocument.get_xml: DomString;
var
  CString,encoding:pchar;
  length:LongInt;
begin
  CString:='';
  encoding:=GDoc.encoding;
  xmlDocDumpMemoryEnc(GDoc,CString,@length,encoding);
  Result:=CString;
end;

function TGDOMDocument.asyncLoadState: Integer;
begin
  Result:=0;
end;

(**
 * Load dom from file
 *)
function TGDOMDocument.load(source: OleVariant): Boolean;
var
  fn: String;
  newdoc: xmlDocPtr;
begin
{$ifdef WIN32}
  fn := StringReplace(UTF8Encode(source), '\', '\\', [rfReplaceAll]);
{$else}
  fn := source;
{$endif}
  newdoc := xmlParseFile(pchar(fn));
  Result := newdoc<>nil;
  if Result then begin
    GDoc := newdoc;
  end;
end;

function TGDOMDocument.loadFromStream(const stream: TStream): Boolean;
begin
  DomAssert(false, NOT_SUPPORTED_ERR);
  Result:=false;
end;

function TGDOMDocument.loadxml(const Value: DomString): Boolean;
var
  newdoc: xmlDocPtr;
  s: String;
begin
  s := UTF8Encode(Value);
  newdoc := xmlParseMemory(PChar(s), Length(s));
  Result := newdoc<>nil;
  if Result then begin
    GDoc := newdoc;
  end;
end;

procedure TGDOMDocument.save(destination: OleVariant);
var
  temp:String;
  encoding:pchar;
  bytes: integer;
begin
  temp:=destination;
  encoding:=GDoc.encoding;
  bytes:=xmlSaveFileEnc(pchar(temp),GDoc,encoding);
  if bytes<0 then DomAssert(false, 22); //write error
end;

procedure TGDOMDocument.saveToStream(const stream: TStream);
begin
  DomAssert(false, NOT_SUPPORTED_ERR);
end;

procedure TGDOMDocument.set_OnAsyncLoad(const Sender: TObject;
  EventHandler: TAsyncEventHandler);
begin
  DomAssert(false, NOT_SUPPORTED_ERR);
end;

function TGDOMDocument.GetGDoc: xmlDocPtr;
begin
  Result := xmlDocPtr(FGNode);
end;

procedure TGDOMDocument.SetGDoc(aNewDoc: xmlDocPtr);
  procedure _DestroyFlyingNodes;
  var
    i: integer;
    node: xmlNodePtr;
    p: pointer;
  begin
    if FFlyingNodes=nil then exit;
    for i:=FFlyingNodes.Count-1 downto 0 do begin
      p := FFlyingNodes[i];
      node := p;
      node._private := nil;
      case node.type_ of
      XML_HTML_DOCUMENT_NODE,
      XML_DOCB_DOCUMENT_NODE,
      XML_DOCUMENT_NODE:
        DomAssert(false, -1, 'This node may never be flying');
      XML_ATTRIBUTE_NODE:
        xmlFreeProp(p);
      XML_DTD_NODE:
        xmlFreeDtd(p);
      else
        xmlFreeNode(p);
      end;
    end;
  end;

  procedure _ReallocateFlyingNodes;
  var
    i: integer;
    node: xmlNodePtr;
  begin
    if FFlyingNodes=nil then exit;
    for i:=FFlyingNodes.Count-1 downto 0 do begin
      node := FFlyingNodes[i];
      case node.type_ of
      XML_HTML_DOCUMENT_NODE,
      XML_DOCB_DOCUMENT_NODE,
      XML_DOCUMENT_NODE:
        DomAssert(false, -1, 'This node may never be flying');
      else
        node.doc := aNewDoc;
      end;
    end;
  end;

var
  old: xmlDocPtr;
begin
  old := GetGDoc;
  if (aNewDoc<>nil) then begin
    _ReallocateFlyingNodes;
    aNewDoc._private := self;
  end else begin
// for some strange reason, the following line makes troubles
//		_DestroyFlyingNodes;
  end;
  FGNode := xmlNodePtr(aNewDoc);
  if (old<>nil) then begin
    old._private := nil;
    xmlFreeDoc(old);
  end;
end;

(**
 * On-demand creation of the underlying document.
 *)
function TGDOMDocument.requestDocPtr: xmlDocPtr;
var
  doc: xmlDocPtr;
begin
  Result := GetGDoc;
  if Result<>nil then exit; //the document is already created so we have to use it
  // otherwise, we create the document, using all the parameters specified so far

  //todo: distinguish empty doc, parsing, and push-parsing cases (for async)
  doc := xmlNewDoc(XML_DEFAULT_VERSION);

  SetGDoc(doc);
end;

function TGDOMDocument.requestNodePtr: xmlNodePtr;
begin
  requestDocPtr;
  Result := FGNode;
end;

function TGDOMDocument.get_ownerDocument: IDomDocument;
begin
  Result := nil; // required by DOM spec.
end;

function TGDOMDocument.GetFlyingNodes: TList;
begin
  if FFlyingNodes=nil then begin
    FFlyingNodes := TList.Create;
  end;
  Result := FFlyingNodes;
end;

function TGDOMDocument.get_nodeType: DOMNodeType;
begin
  Result := DOCUMENT_NODE;
end;

function TGDOMDocument.get_nodeName: DomString;
begin
  Result := '#document';
end;

procedure TGDOMDocument.set_nodeValue(const value: DomString);
begin
  DomAssert(False, NO_MODIFICATION_ALLOWED_ERR);
end;

{ TGDOMCharacterData }

procedure TGDOMCharacterData.appendData(const data: DomString);
begin
  xmlNodeAddContent(FGNode, PChar(UTF8Encode(data)));
end;

procedure TGDOMCharacterData.deleteData(offset, count: Integer);
begin
  replaceData(offset, count, '');
end;

function TGDOMCharacterData.get_length: Integer;
begin
  Result := Length(get_nodeValue);
end;

procedure TGDOMCharacterData.insertData(offset: Integer; const data: DomString);
begin
  replaceData(offset, 0, PChar(UTF8Encode(data)));
end;

procedure TGDOMCharacterData.replaceData(offset, count: Integer; const data: DomString);
var
  s1,s2,s: WideString;
begin
  s := get_nodeValue;
  s1 := Copy(s, 1, offset);
  s2 := Copy(s, offset + count+1, Length(s)-offset-count);
  set_nodeValue(s1 + data + s2);
end;

function TGDOMCharacterData.substringData(offset, count: Integer): DomString;
//var
//  temp:PGdomeDomString;
begin
  DomAssert(false, NOT_SUPPORTED_ERR);
  {temp:=gdome_cd_substringData(GCharacterData,offset,count,@exc);
  DomAssert(false, exc);
  Result:=GdomeDOMStringToString(temp);}
end;

{ TGDOMText }

function TGDOMText.splitText(offset: Integer): IDomText;
begin
  set_nodeValue(Copy(get_nodeValue, 1, offset));
  Result := self;
end;

{ TMSDOMEntity }

function TGDOMEntity.get_notationName: DomString;
begin
  DomAssert(false, NOT_SUPPORTED_ERR);
  //Result:=GdomeDOMStringToString(gdome_ent_notationName(GEntity,@exc));
  //DomAssert(exc);
end;

function TGDOMEntity.get_publicId: DomString;
begin
  DomAssert(false, NOT_SUPPORTED_ERR);
  //Result:=GdomeDOMStringToString(gdome_ent_publicID(GEntity,@exc));
  //DomAssert(exc);
end;

function TGDOMEntity.get_systemId: DomString;
begin
  DomAssert(false, NOT_SUPPORTED_ERR);
  //Result:=GdomeDOMStringToString(gdome_ent_systemID(GEntity,@exc));
end;

{ TGDOMDocumentType }

function TGDOMDocumentType.get_entities: IDomNamedNodeMap;
//var entities: PGdomeNamedNodeMap;
//    exc: GdomeException;
begin
  DomAssert(false, NOT_SUPPORTED_ERR);
  {entities:=gdome_dt_entities(GDocumentType,@exc);
  DomAssert(exc);
  if entities<>nil
    then Result:=TGDOMxxx.Create(entities,FOwnerDocument) as IDomNamedNodeMap
    else Result:=nil;}
end;

function TGDOMDocumentType.get_internalSubset: DomString;
var
  buff: xmlBufferPtr;
begin
  buff := xmlBufferCreate();
  xmlNodeDump(buff,nil,xmlNodePtr(GetGDocumentType),0,0);
  Result := UTF8Decode(buff.content);
  xmlBufferFree(buff);
end;

function TGDOMDocumentType.get_name: DomString;
begin
  Result := self.get_nodeName;
end;

function TGDOMDocumentType.get_notations: IDomNamedNodeMap;
//var
//  notations: PGdomeNamedNodeMap;
//  exc: GdomeException;
begin
  DomAssert(false, NOT_SUPPORTED_ERR);
  //Implementing this method requires to implement a new
  //type of NodeList
  //GetGDocumentType.notations;
  {notations:=gdome_dt_notations(GDocumentType,@exc);
  DomAssert(exc);
  if notations<>nil
    then Result:=TGDOMxxxx.Create(notations,FOwnerDocument) as IDomNamedNodeMap
    else Result:=nil;}
end;

function TGDOMDocumentType.get_publicId: DomString;
begin
  Result := UTF8Decode(GetGDocumentType.ExternalID);
end;

function TGDOMDocumentType.get_systemId: DomString;
begin
  Result := UTF8Decode(GetGDocumentType.SystemID);
end;

function TGDOMDocumentType.GetGDocumentType: xmlDtdPtr;
begin
  Result := xmlDtdPtr(GNode);
end;

{ TGDOMNotation }

function TGDOMNotation.get_publicId: DomString;
//var
//  temp: String;
begin
  DomAssert(false, NOT_SUPPORTED_ERR);
  //temp:=GdomeDOMStringToString(gdome_not_publicId(GNotation, @exc));
  //DomAssert(exc);
  //Result:=temp;
end;

function TGDOMNotation.get_systemId: DomString;
//var
//  temp: String;
begin
  DomAssert(false, NOT_SUPPORTED_ERR);
  //temp:=GdomeDOMStringToString(gdome_not_systemId(GNotation, @exc));
  //DomAssert(exc);
  //Result:=temp;
end;

initialization
  RegisterDomVendorFactory(TGDOMDocumentBuilderFactory.Create(False));
finalization
  // release on-demand created instances
  GDOMImplementation[false] := nil;
  GDOMImplementation[true] := nil;
end.


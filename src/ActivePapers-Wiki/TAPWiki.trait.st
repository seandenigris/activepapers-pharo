Trait {
	#name : #TAPWiki,
	#category : #'ActivePapers-Wiki'
}

{ #category : #accessing }
TAPWiki classSide >> createOrRetrieveWikiPageNamed: aString [
	^ (self wikiPageNamed: aString)
		ifNil: [ 
			(APWikiPage
				wiki: self
				name: aString
				text: self initialWikiPageContents) store ]
]

{ #category : #inspecting }
TAPWiki classSide >> gtMainPageFor: aView [
	<gtView>
	| aDocument |
	aDocument := GtDocument new
							strategy: (APWikiPageStorageStrategy new container: self; name: #Main);
							read.
	^ (aDocument gtTextFor: aView)
		title: 'Main page';
		priority: -10;
		action: [ :anAction | 
			aDocument gtSaveActionFor: anAction ];
		action: [ :anAction | 
			aDocument gtShowMarkupActionFor: anAction ]
]

{ #category : #inspecting }
TAPWiki classSide >> gtPagesFor: aView [
	<gtView>
	<gtClassView>
	^ aView list
		title: 'Pages' translated;
		priority: -9;
		items: [ self wikiPageNames collect: [ :pn | self wikiPageNamed: pn ] ];
		itemText: [ :page | page name ]
]

{ #category : #testing }
TAPWiki classSide >> hasWikiPageNamed: aSymbol [
	^ aSymbol = #Main
		or: [ self respondsTo: (self methodSelectorForWikiPageNamed: aSymbol) ]
]

{ #category : #accessing }
TAPWiki classSide >> initialWikiPageContents [
	^ '!New page'
]

{ #category : #accessing }
TAPWiki classSide >> methodSelectorForWikiPageNamed: aString [
	| safeName |
	safeName := aString copyReplaceAll: ' ' with: '_'.
	^ ('wikiPage', safeName) asSymbol
]

{ #category : #accessing }
TAPWiki classSide >> normalizeWikiPageName: aSymbol [
	^ aSymbol capitalized
]

{ #category : #deleting }
TAPWiki classSide >> removeWikiPageNamed: aSymbol [
	self class removeSelector: (self methodSelectorForWikiPageNamed: aSymbol)
]

{ #category : #accessing }
TAPWiki classSide >> store: contentString inWikiPageNamed: pageName [
	| code |

	pageName = #Main
		ifTrue: [ self comment: contentString. ^ self ].

	code := String streamContents: [ :s |
		s nextPutAll: (self methodSelectorForWikiPageNamed: pageName).
		s crtab; nextPutAll: '"This method was automatically generated."'.
		s crtab; nextPutAll: '<wikiPage: '; nextPutAll: pageName storeString; nextPutAll: '>'.
		s crtab; nextPutAll: '^APWikiPage'.
		s crtab: 2; nextPutAll: 'wiki: self'.
		s crtab: 2; nextPutAll: 'name: '; nextPutAll: pageName storeString.
		s crtab: 2; nextPutAll: 'text: '.
		s cr; nextPutAll: contentString storeString.
	].

	self class compile: code classified: 'wikiPages'.
]

{ #category : #accessing }
TAPWiki classSide >> wikiEvaluationReceiverForPage: aSymbol [
	"The evaluationReceiver for scripts embedded into Wiki pages.
	By default it is the class, for all pages, but classes can override this method."
	^ self
]

{ #category : #accessing }
TAPWiki classSide >> wikiPageNamed: aString [
	aString = #Main
		ifTrue: [ ^ APWikiPage wiki: self name: aString text: self comment ].
	^ [ self perform: (self methodSelectorForWikiPageNamed: aString) ]
		on: MessageNotUnderstood do: [ nil ]
		
]

{ #category : #accessing }
TAPWiki classSide >> wikiPageNames [
	| pageNames |
	pageNames := ((Pragma allNamed: #wikiPage: in: self class)
						collect: [ :p | p argumentAt: 1 ])
					 	asOrderedCollection.
	pageNames sort.
	pageNames addFirst: #Main.
	^ pageNames asArray
]

# B2BCPQ

cool project

From Launch Flow From Model Component (Salesforce Labs - https://salesforce.quip.com/AgKjAEz9UDfI) (which is basically a "Request for Quote" button), you can call a Flow that will execute these Invokable Apex methods to create both an Opportunity and a Quote.

IMPORTANT: 

* Currently must disable CPQ *and* Billing triggers because running a Flow as a System User does not apply to object triggers that may execute outside of the context of the Flow.
* Add QuoteID field to Cart Object

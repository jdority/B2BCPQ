public class B2BCreateQuote { 
    @InvocableMethod
    public static List<B2BQuote> getQuoteItems(List<String> opptyID) {
        
        String x = opptyID[0];
        return new List<B2BQuote>{getQuote(x)};           
            }
    
    private static B2BQuote getQuote(String opptyID) {                                        
        //Get ID and AccountID from Opportunity
        //Get list of Products from Opportunity Product
        List<Opportunity> Oppty = [SELECT ID, AccountID FROM Opportunity WHERE ID = :opptyID];
        List<OpportunityLineItem> OpptyLIs = [SELECT Product2Id, Quantity, TotalPrice FROM OpportunityLineItem WHERE OpportunityId = :opptyID];
        
        //Create Quote
        //Pricebook2Id: HARDCODE Standard PriceBook
        SBQQ__Quote__c q = new SBQQ__Quote__c(SBQQ__Primary__c = true, 
                                              SBQQ__Account__c = Oppty[0].AccountID, 
                                              SBQQ__Opportunity2__c = Oppty[0].ID,
                                              SBQQ__SubscriptionTerm__c = 12, 
                                              SBQQ__Status__c = 'In Review', 
                                              SBQQ__Type__c = 'Quote', 
                                              SBQQ__Notes__c = 'eCommerce Request',
                                              SBQQ__PriceBook__c = '01s4W000004shKjQAI');
        
        List<Contact> ContactList = [SELECT Id FROM Contact WHERE AccountId = :Oppty[0].AccountID LIMIT 1];
        if (ContactList.size() > 0) {
            q.SBQQ__PrimaryContact__c = ContactList.get(0).Id;
        }
        
        SBQQ.TriggerControl.disable();
        Database.insert(q);
           
        List<B2BQuote> listOfQuotes = new List<B2BQuote>{};
		B2BQuote a = new B2BQuote();
        a.cool_quoteID = q.id;
        listOfQuotes.add(a);
        
        //Create Quote Lines by looping through Opportunity Product Lines
        for (OpportunityLineItem currentOpportunityLineItem : OpptyLIs) {
            SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
            ql.SBQQ__Product__c = currentOpportunityLineItem.Product2ID;
            ql.SBQQ__Quantity__c = currentOpportunityLineItem.Quantity;
            ql.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            ql.SBQQ__Quote__c = q.id;
            Database.insert(ql);       
        }     
        SBQQ.TriggerControl.enable();
        System.debug('****** Debug :   ' + listOfQuotes[0]);
        return listOfQuotes[0];
    }
}

//https://help.salesforce.com/articleView?id=cpq_triggers_community.htm&type=0
//https://help.salesforce.com/articleView?id=000352041&language=en_US&mode=1&type=1
//https://katiekodes.com/flow-apex-defined-data-types/
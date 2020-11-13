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
        
        //Get Standard Price Book ID
        List<Pricebook2> pb = [SELECT ID from Pricebook2 WHERE Name ='Standard Price Book'];
        
        //Create Quote
        //Pricebook2Id: HARDCODE Standard PriceBook
        SBQQ__Quote__c q = new SBQQ__Quote__c(SBQQ__Primary__c = true, 
                                              SBQQ__Account__c = Oppty[0].AccountID, 
                                              SBQQ__Opportunity2__c = Oppty[0].ID,
                                              SBQQ__SubscriptionTerm__c = 12, 
                                              SBQQ__Status__c = 'In Review', 
                                              SBQQ__Type__c = 'Quote', 
                                              SBQQ__Notes__c = 'eCommerce Request',
                                              SBQQ__PriceBook__c = pb[0].ID);
        
        List<Contact> ContactList = [SELECT Id FROM Contact WHERE AccountId = :Oppty[0].AccountID LIMIT 1];
        if (ContactList.size() > 0) {
            q.SBQQ__PrimaryContact__c = ContactList.get(0).Id;
        }
        
        //Disable CPQ Triggers for Quote Insert 
        SBQQ.TriggerControl.disable();
        Database.insert(q);

        List<B2BQuote> listOfQuotes = new List<B2BQuote>{};
		B2BQuote a = new B2BQuote();
        a.cool_quoteID = q.id;
        listOfQuotes.add(a);
        
        //Create **Quote Lines by looping through Opportunity Product Lines
        for (OpportunityLineItem currentOpportunityLineItem : OpptyLIs) {
            SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
            ql.SBQQ__Product__c = currentOpportunityLineItem.Product2ID;
            ql.SBQQ__Quantity__c = currentOpportunityLineItem.Quantity;
            ql.SBQQ__Number__c = currentOpportunityLineItem.Quantity;
            ql.SBQQ__ProrateMultiplier__c = currentOpportunityLineItem.Quantity;
            ql.SBQQ__SubscriptionPricing__c = 'Fixed Price';
            ql.SBQQ__Quote__c = q.id;
            ql.SBQQ__SubscriptionTerm__c = q.SBQQ__SubscriptionTerm__c;
            ql.SBQQ__DefaultSubscriptionTerm__c = q.SBQQ__SubscriptionTerm__c;
            ql.SBQQ__ChargeType__c = 'Recurring';
            ql.SBQQ__BillingType__c = 'Advance';
            ql.SBQQ__BillingFrequency__c = 'Monthly';
            ql.SBQQ__SubscriptionBase__c ='List';
            ql.SBQQ__ProductSubscriptionType__c = 'Renewable';
            ql.SBQQ__SubscriptionType__c = 'Renewable';
                   
            //Retrieve PriceBook Entry for STANDARD PRICE BOOK for the Product
            List<PricebookEntry> pbe = 
                	[SELECT Id, UnitPrice FROM PricebookEntry 
                      WHERE Pricebook2Id = :pb[0].ID AND Product2Id = :currentOpportunityLineItem.Product2ID];
            
            ql.SBQQ__PricebookEntryId__c = pbe[0].id;
            ql.SBQQ__NetPrice__c = pbe[0].UnitPrice;
            ql.SBQQ__CustomerPrice__c = pbe[0].UnitPrice;
            ql.SBQQ__ListPrice__c = pbe[0].UnitPrice;
            ql.SBQQ__OriginalPrice__c = pbe[0].UnitPrice;
            ql.SBQQ__PartnerPrice__c = pbe[0].UnitPrice;
            ql.SBQQ__ProratedListPrice__c = pbe[0].UnitPrice;
            ql.SBQQ__ProratedPrice__c = pbe[0].UnitPrice;
            ql.SBQQ__RegularPrice__c = pbe[0].UnitPrice;
            ql.SBQQ__SpecialPrice__c = pbe[0].UnitPrice;
            
            Database.insert(ql);  
            
            //Update the Opportunity Product Line with the Quote Line ID
            currentOpportunityLineItem.SBQQ__QuoteLine__c = ql.id;
            Database.upsert(currentOpportunityLineItem);
            
        }  
        	//Re-enable CPQ Triggers
            SBQQ.TriggerControl.enable();
     
        System.debug('****** Debug :   ' + listOfQuotes[0]);
        return listOfQuotes[0];
    }
}

//https://help.salesforce.com/articleView?id=cpq_triggers_community.htm&type=0
//https://help.salesforce.com/articleView?id=000352041&language=en_US&mode=1&type=1
//https://katiekodes.com/flow-apex-defined-data-types/
//https://developer.salesforce.com/docs/atlas.en-us.cpq_dev_api.meta/cpq_dev_api/cpq_quote_api_calculate_final.htm
//https://developer.salesforce.com/docs/atlas.en-us.cpq_dev_api.meta/cpq_dev_api/cpq_api_quote_model_9.htm
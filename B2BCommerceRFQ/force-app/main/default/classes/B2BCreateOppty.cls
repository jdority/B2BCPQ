global class B2BCreateOppty {
    
    @InvocableMethod
    public static List<B2BOppty> getCartItems(List<String> cartID) {
        
        String x = cartID[0];
        return new List<B2BOppty>{getOppty(x)};          
            }
    
    private static B2BOppty getOppty(String cartID) {                                        
        //Get Account ID and Owner (User) from WebCart (Cart Header)
        //Get list of Products from cartItems
        List<WebCart> WebCart = [SELECT ID, AccountID, OwnerID FROM WebCart WHERE ID = :cartID];
        List<CartItem> cartItems = [SELECT Product2Id, Quantity, TotalPrice FROM CartItem WHERE CartID = :cartID];
        
        //Create Opportunity
        //Pricebook2Id: HARDCODE Standard Price Book
        Opportunity opp = new Opportunity(CloseDate = date.valueOf('2022-12-31'), AccountId = Webcart[0].AccountID, StageName = 'Qualification', Name = 'Subscription Opportunity',Pricebook2Id = '01s4W000004shKfQAI');
        
        //SBQQ.TriggerControl.disable();
        Database.insert(opp);
        
        List<B2BOppty> listOfOpptys = new List<B2BOppty>{};
		B2BOppty a = new B2BOppty();
        a.cool_opptyID = opp.id;
        listOfOpptys.add(a);
        
        //Create Opporunity Product Lines by looping through Cart Items
        for (CartItem currentCartItem : cartItems) {
            OpportunityLineItem ol = new OpportunityLineItem();
            ol.OpportunityId = a.cool_opptyID;
            ol.Product2Id = currentCartItem.Product2ID;
            ol.Quantity = currentCartItem.Quantity;
            ol.TotalPrice = currentCartItem.TotalPrice;
            
            Database.insert(ol);        
        }   
        //SBQQ.TriggerControl.enable();
        System.debug('****** Debug :   ' + listOfOpptys[0]);
        return listOfOpptys[0];
    }
}

//https://katiekodes.com/flow-apex-defined-data-types/
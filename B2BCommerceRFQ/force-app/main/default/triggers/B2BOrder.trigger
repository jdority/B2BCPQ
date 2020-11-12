trigger B2BOrder on Order (before insert) {
    
    //B2B Commerce Checkout Flow must supply a Pricebook2 ID to be compatible with Billing
    
    List<Pricebook2> p = [SELECT ID FROM Pricebook2 WHERE Name = 'Standard Price Book'];
    //system.debug(p[0].id);

    for(Order o : Trigger.New) {
        
        if (String.isEmpty(o.Pricebook2Id)) {
            o.Pricebook2Id = p[0].ID;
        }
    }   
}
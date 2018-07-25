module RequestsHelper
  def progress_title(request)
    prog = []
    if request.accepted?
      prog << 'Akzeptiert'
    end
    if request.contract.deposit_paid?
      prog << 'Kaution bezahlt'
    end
    if request.contract.passport_verified?
      prog << 'Ausweis verifiziert'
    end
    if request.contract.contract_verified?
      prog << 'Unterschrift verifiziert'
    end
    if request.contract.signed_contract
      prog << 'Mieter hat unterschrieben'
    end
    if request.contract.passport
      prog << 'Ausweiskopie hinterlegt'
    end
    prog.empty? ? 'Warten auf Antwort des Vermieters' : prog.join(", ")
  end
end

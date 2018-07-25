module DefaultDocumentGenerator
  extend self

  def generate_contract(contract)
    tmp_file = Tempfile.new(["vertrag", ".pdf"])

    contract.instance_eval do
      Prawn::Document.generate(tmp_file.path) do |pdf|
        pdf.define_grid(:columns => 5, :rows => 8, :gutter => 10)
        pdf.font "Helvetica"
        pdf.font_size = 11

        pdf.font("Helvetica", :style => :bold, :size => pdf.font_size + 4) do
          pdf.text account.public_name, :align => :center
          pdf.text "#{account.company_address} - #{account.company_zip} - #{account.company_city}", :align => :center
        end

        pdf.bounding_box [pdf.bounds.left,pdf.cursor], :width => pdf.bounds.width do
          pdf.bounding_box [pdf.bounds.left, pdf.bounds.top], :width => pdf.bounds.width / 2 do
            pdf.text user.anrede
            pdf.text user.fullname
            pdf.text user.address
            pdf.text "#{user.zip} #{user.city}"
            pdf.text "Tel.: #{user.phone}" if !user.phone.blank?
            pdf.text "Mobil: #{user.mobile}" if !user.mobile.blank?
            pdf.text "Fax: #{user.fax}" if !user.fax.blank?
            pdf.text "E-Mail: #{user.email}"
            pdf.font("Helvetica", :style => :bold) do
              pdf.text "Kundennummer: #{user.id}"
              #pdf.text "Kautionsnummer: #{u}"
              pdf.text "Vertragsnummer: #{id}"
            end
            1.times { pdf.text " " }

            pdf.font("Helvetica", :style => :bold) do
              pdf.text "Allgemeine Vertragsinformationen"
            end

          end
          pdf.bounding_box [pdf.bounds.width / 2, pdf.bounds.top], :width => pdf.bounds.width / 2 do
            pdf.text account.company, :align => :right
            pdf.text " ", :align => :right
            pdf.text account.company_address, :align => :right
            pdf.text [account.company_zip, account.company_city] * "", :align => :right
            pdf.text " ", :align => :right
            pdf.font("Helvetica", :style => :bold) do
              pdf.text "Tel.: +49 [0] #{account.phone}", :align => :right
            end
            pdf.text "Fax: + 49 [0] #{account.fax}", :align => :right
            pdf.text "Page: #{account.website}", :align => :right
            pdf.text "E-Mail: #{account.email}", :align => :right
            1.times { pdf.text " " }
            pdf.font("Helvetica", :style => :bold) do
              pdf.text "#{account.company_city}, den #{I18n.l(created_at.to_date)}", :align => :right
            end
          end
        end

        pdf.text "Zwischen", :style => :bold

        pdf.grid([2.3,0], [2.3,3]).bounding_box do
          pdf.text user.fullname
          pdf.text user.address
          pdf.text "#{user.zip} #{user.city}"
          pdf.text user.country
          pdf.text " "
          pdf.text "Nachfolgend Mieter genannt"
        end
        pdf.grid(2.3,2).bounding_box do
          pdf.text " "
          pdf.text "und", :style => :bold
        end

        pdf.grid([2.3,3], [2.3,6]).bounding_box do
          pdf.text account.company.to_s
          pdf.text account.company_address.to_s
          pdf.text "#{account.company_zip.to_s} #{account.company_city.to_s}"
          pdf.text account.company_country.to_s
          pdf.text " "
          pdf.text "Nachfolgend Vermieter genannt"

        end
        pdf.text "wird ein Mietvertrag zur Nutzung einer Wohneinheit(#{rentable_item.room_count || 1} Zimmer) mit folgenden Vertragsdaten geschlossen:"
        pdf.text " "

        pdf.text "Die Wohneinheit befindet sich im Objekt #{rentable_item.full_address} und besitzt die bei couchpotatoe.com eingetragenen Annehmlichkeiten (#{rentable_item.item_type_attributes.map(&:value).join(', ')})."
        pdf.text " "

        pdf.text "Der Mieter ist sich bewusst, dass er entweder uns ein SEPA-Mandat(Referenz: #{ id }) zur Abbuchung der Mieten von seinem Konto per Lastschrift genehmigt oder unter der Angabe des Verwendungszwecks('Miete Nr.: #{ id } MONAT JAHR') an das unten genannte Konto überweist."
        pdf.text "Die Miete ist pünktlich zum vereinbarten Zahlungsziel(15. der Vormonats bzw. spätestens 5 Tage nach Buchung) zu bezahlen."
        pdf.text " "

        pdf.text "Die Kaution ist spätestens bis 5 Tage vor Vertragsbeginn auf das Konto des Vermieters, Name: #{account.bank_account_owner}, IBAN: #{account.iban}, BIC: #{account.bic}, mit dem Verwendungszweck 'Kaution Nr.: #{id}' zu überweisen. Erhält der Vermieter die Kaution  nicht rechtzeitig, so behält er sich vor, den Mietvertrag außerordentlich zu Kündigen."
        pdf.text " "

        pdf.table([
                    ["Folgende Wohneinheit im o.g. Objekt wird gemäß Vertrag angemietet (couchpotatoe.com ID):", rentable_item.id],
                    ["Die monatliche Miete für die oben angegebene Wohneinheit beträgt:", "%.2f €" % price],
                    ["Zusätzliche monatliche Kosten:", contract.billing_items.contract_monthly.map { |bi| "#{bi.name}: #{number_to_currency(bi.price)}" }.join(", ")],
                    ["Die Kaution für die oben angegebene Wohneinheit beträgt:", "%.2f €" % deposit],
                    ["Der Vertragsbeginn für die oben angegebene Wohneinheit ist:", I18n.l(start_date.to_date)],
                    ["Das Vertragsende für die oben angegebene Wohneinheit ist:", end_date ? I18n.l(end_date.to_date) : 'unbefristet'],
                  ],
                  {  :cell_style => {:border_width => 0, :padding => 0 }}
        )

        pdf.grid([7,0], [7,1]).bounding_box do
          pdf.text "Unterschrift Mieter"
        end

        pdf.grid([7,3], [7,4]).bounding_box do
          pdf.text "Unterschrift Vermieter"
        end
      end
    end
    tmp_file
  end


  def generate_direct_debit_form(contract)

    tmp_file = Tempfile.new(["direct_debit", ".pdf"])

    contract.instance_eval do
      Prawn::Document.generate(tmp_file.path) do |pdf|
        pdf.font("Helvetica", :size => 12)

        pdf.font("Helvetica", :style => :bold, :size => pdf.font_size + 2) do
          pdf.text " "
          pdf.text "Erteilung eines SEPA-Mandats zur Einziehung von Forderungen durch Lastschrift"
          pdf.text " "
        end

        pdf.text user.anrede
        pdf.text user.fullname
        pdf.text user.address
        pdf.text "#{user.zip} #{user.city}"
        pdf.text " "
        pdf.text "Tel.: #{user.phone}" if !user.phone.blank?
        pdf.text "Mob.: #{user.mobile}" if !user.mobile.blank?
        pdf.text "Fax: #{user.fax}" if !user.fax.blank?
        pdf.text "E-Mail: #{user.email}"
        pdf.font("Helvetica", :style => :bold) do
          pdf.text "Kundennummer: #{user.debitoren_nr}"
        end

        pdf.text <<-REST_DER_WELT

        Ich ermächtige die #{account.company} widerruflich, die von mir zu entrichtenden Zahlungen bei Fälligkeit zu Lasten meines Girokontos

        Inhaber: #{user.bank_account_holder}

        IBAN: #{user.iban_prettified}

        BIC: #{user.bic}

        bei: #{user.bank_name}

        per Lastschrift einzuziehen. Die zugehörige Mandats-ID ist #{id} und die Mandatslaufzeit entspricht der Vertragslaufzeit.

        Sollte mein Konto die erforderliche Deckung nicht aufweisen, besteht seitens des kontoführenden Kreditinstitutes keine Verpflichtung zur Einlösung. Teileinlösungen werden im Lastschriftverfahren nicht angenommen.
        REST_DER_WELT

        4.times { pdf.text " " }

        pdf.bounding_box [pdf.bounds.left,pdf.cursor], :width => pdf.bounds.width do
          pdf.bounding_box [pdf.bounds.left, pdf.bounds.top], :width => 150 do
            pdf.move_down 3
            pdf.text "Ort, Datum"
            pdf.stroke do
              pdf.line pdf.bounds.top_left, pdf.bounds.top_right
            end
          end
          pdf.bounding_box [pdf.bounds.left + 150, pdf.bounds.top], :width => pdf.bounds.width - 150 do
            pdf.move_down 3
            pdf.text user.fullname
            pdf.stroke do
              pdf.line pdf.bounds.top_left, pdf.bounds.top_right
            end
          end
        end

        pdf.text <<-REST_DER_WELT

        Kosten, die durch Lastschriftrückläufer entstehen, werden in Rechnung gestellt. Bei Lastschriftrückläufern behält sich #{account.company} die Kündigung des Vertragsverhältnisses vor.
        REST_DER_WELT
      end
    end
    tmp_file
  end
end

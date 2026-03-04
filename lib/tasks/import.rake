namespace :import do
  desc "Importa presentes de lista_presentes.csv"
  task gifts: :environment do
    require "csv"
    file_path = Rails.root.join("lista_presentes.csv")

    # Categorias do CSV podem vir capitalizadas ou com nomes alternativos
    CATEGORY_MAP = {
      "banheiro"   => "banheiro",
      "quarto"     => "quarto",
      "cozinha"    => "cozinha",
      "sala"       => "sala",
      "jardim"     => "jardim",
      "escritorio" => "escritorio",
      "decoracao"  => "decoracao",
      "eletronico" => "eletronico",
      "limpeza"    => "outro",   # não existe no sistema, mapeado para "outro"
      "outro"      => "outro"
    }.freeze

    imported = 0
    skipped  = 0
    errors   = []

    CSV.foreach(file_path, headers: true, encoding: "bom|UTF-8") do |row|
      name = row["name"].to_s.strip
      next if name.blank?

      raw_category = row["category"].to_s.strip.downcase
      category     = CATEGORY_MAP.fetch(raw_category, "outro")
      description  = row["description"].to_s.strip.presence
      quantity     = [ row["quantity"].to_s.strip.to_i, 1 ].max

      gift = Gift.new(name: name, category: category, description: description, quantity: quantity)

      if gift.save
        imported += 1
        puts "  ✓ #{name} (#{category}, qty: #{quantity})"
      else
        msg = gift.errors.full_messages.join(", ")
        errors << "  ✗ #{name}: #{msg}"
        skipped += 1
      end
    end

    puts "\n=== Resultado — Presentes ==="
    puts "Importados : #{imported}"
    puts "Com erro   : #{skipped}"
    errors.each { |e| puts e }
  end

  desc "Importa convidados de lista_convidados.csv"
  task guests: :environment do
    require "csv"
    file_path = Rails.root.join("lista_convidados.csv")

    # Primeira passagem: agrupa linhas em [principal_row, [companion_rows]]
    groups            = []
    current_principal = nil
    current_companions = []

    CSV.foreach(file_path, headers: true, encoding: "bom|UTF-8") do |row|
      name         = row["full_name"].to_s.strip
      next if name.blank?

      is_principal = row["principal"].to_s.strip.downcase == "sim"

      if is_principal
        groups << [ current_principal, current_companions ] if current_principal
        current_principal  = row
        current_companions = []
      else
        current_companions << row
      end
    end
    groups << [ current_principal, current_companions ] if current_principal

    imported_principals = 0
    imported_companions = 0
    errors              = []

    groups.each do |principal_row, companion_rows|
      full_name        = principal_row["full_name"].to_s.strip
      phone            = principal_row["phone"].to_s.strip.presence
      companions_count = companion_rows.size

      principal = Guest.new(
        full_name:        full_name,
        phone:            phone,
        companions_count: companions_count
      )

      unless principal.save
        errors << "✗ #{full_name}: #{principal.errors.full_messages.join(', ')}"
        next
      end

      imported_principals += 1
      puts "  ✓ #{full_name} (#{companions_count} acompanhante(s))"

      companion_rows.each do |comp_row|
        comp_name  = comp_row["full_name"].to_s.strip
        comp_phone = comp_row["phone"].to_s.strip.presence

        companion = Guest.new(
          full_name:        comp_name,
          phone:            comp_phone,
          companions_count: 0,
          principal:        principal
        )

        if companion.save
          imported_companions += 1
          puts "    → #{comp_name}"
        else
          errors << "    ✗ Acompanhante '#{comp_name}' (de #{full_name}): #{companion.errors.full_messages.join(', ')}"
        end
      end
    end

    puts "\n=== Resultado — Convidados ==="
    puts "Responsáveis importados : #{imported_principals}"
    puts "Acompanhantes importados: #{imported_companions}"
    puts "Total                   : #{imported_principals + imported_companions}"
    puts "Com erro                : #{errors.size}"
    errors.each { |e| puts e }
  end

  desc "Importa presentes e convidados (atalho)"
  task all: [ "import:gifts", "import:guests" ]
end

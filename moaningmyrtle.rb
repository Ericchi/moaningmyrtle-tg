## - Moaning Myrtle by EricchiYukia -
## Requires editing to get this working correctly
## Check config.rb before launching this bot
##
## Source is distributed under the AGPL v3.0
## https://www.gnu.org/licenses/agpl-3.0.html

require 'telegram/bot'
require 'megahal'
require_relative("config.rb")
require 'date'
require 'digest'

botPath = File.dirname(__FILE__) + "/"
ai = MegaHAL.new
bot_id = $botToken.split(':').at(0).to_i
scalar = 0.00
t0, t1 = Time.now
decision = 0
messages = 0

if File.exist?($botPath + '.lastday')
  puts "Last day file exists."
else
  out_file = File.new($botPath + ".lastday", "w")
  out_file.puts(Date.today)
  out_file.close
  puts "Last day file was created."
end
lastdayfile = File.open($botPath + ".lastday")
lastdayfile_data = lastdayfile.read

### ADVANCED CONFIG ###
# Increase this number to make auto-complaints less frequent:
maxrandom = 4096.00
# Minimum time between complaints:
timeinit = 300.00
# Dreams artificial intelligence (comment out if not needed):
aiDream = MegaHAL.new
aiDream.load(botPath + 'dreams.brn') if File.file?(botPath + 'dreams.brn')
### END OF ADVANCED CONFIG ###

ai.load(botPath + 'brain.brn') if File.file?(botPath + 'brain.brn')

Telegram::Bot::Client.run($botToken) do |bot|
  bot.listen do |message|
    case message
      # Unused inline stuff
    when Telegram::Bot::Types::InlineQuery
      if message.query.end_with? '.'
        puts "Processing inline query -- #{message.query}"

        results = [
          [1, 'Lorem', 'Ipsum']
        ].map do |arr|
          Telegram::Bot::Types::InlineQueryResultArticle.run(
          id: arr[0],
          title: arr[1],
          input_message_content: Telegram::Bot::Types::InputTextMessageContent.new(message_text: ai.reply(message.query))
          )
        end

        bot.api.answer_inline_query(inline_query_id: message.id, results: results)
      else
        next
      end
    when Telegram::Bot::Types::Message
      reply = nil
      text = message.text.dup rescue ''
      # Debug
      puts "" + Time.now.to_s + " Message: #{text} -- Chat type: #{message.chat.type} ID: #{message.chat.id}"
      # End debug
      currentDate = Date.today
      #if message.chat.type == 'supergroup'
      if message.chat.id == $tgGroupID
        t1 = Time.now
        messages += 1
        puts "RNG: #{decision} - Scalar: #{scalar} - Time: #{t1-t0}"
        if t1-t0 >= timeinit
          scalar += 1
          decision = rand(maxrandom)-scalar
          if File.exist?(botPath + '.autodeactivated')
            puts "Lagne automatiche disattivate"
          else
            if decision < 0
              sleep 5
              reply = ai.reply("")
              bot.api.send_message(chat_id: $tgGroupID, text: reply)
              scalar = 0
              messages = 0
              t0 = Time.now
              puts "Writing a message -- #{message.chat.type} #{message.chat.id}"
            end
          end
        end

        if message.text =~ /\/lagna@#{$botName}/i
          reply = ai.reply("")
          bot.api.send_message(chat_id: $tgGroupID, text: reply)
          puts "Comando Lagna -- Chat type: #{message.chat.type} ID: #{message.chat.id}"
        end
        # Dream section
        if message.text =~ /\/sogna@#{$botName}/i
          reply = aiDream.reply("")
          bot.api.send_message(chat_id: $tgGroupID, text: reply)
          puts "Comando Sogno -- Chat type: #{message.chat.type} ID: #{message.chat.id}"
        end
        # End of dream section

        # Goodmorning section
        lastdayfile = File.open($botPath + ".lastday")
        lastdayfile_data = lastdayfile.read
        if currentDate != Date.parse(lastdayfile_data) && t1.hour >= $awakeHour
          puts "Date check is valid."
          puts currentDate
          puts lastdayfile_data
          puts t1.hour
          if File.exist?($botPath + '.lastday')
            File.delete($botPath + '.lastday')
            out_file = File.new($botPath + ".lastday", "w")
            out_file.puts(Date.today)
            out_file.close
          end
          currentDate = Date.today
          bot.api.send_message(chat_id: $tgGroupID, text: $newDayMessage.sample)
          reply = aiDream.reply("")
          bot.api.send_message(chat_id: $tgGroupID, text: reply)
          puts "Sending new day message -- #{message.chat.type} #{message.chat.id}"
        end
        # End of goodmorning section

        if message.text =~ /\/status@#{$botName}/i
          $deactivated = "Attivate"
          if File.exist?(File.dirname(__FILE__) + '/.deactivated')
            $deactivated = "Disattivate"
          end
          version = `git rev-parse --short HEAD`
          url = `git remote get-url origin`
          status = "Moaning Myrtle #{version}#{url}\nMessaggi dall'ultima autolagna (o dal reboot): #{messages}\nTempo minimo tra lagne: #{timeinit} secondi\nProbabilità di autolagnarmi: #{(scalar/maxrandom)*100}%\nLagne automatiche: #{$deactivated}"
          bot.api.send_message(chat_id: $tgGroupID, text: status)
          puts "Comando Status -- Chat type: #{message.chat.type} ID: #{message.chat.id}"
        end
        if message.text =~ /\/toggle@#{$botName}/i
          if File.exist?($botPath + '.deactivated')
            File.delete($botPath + '.deactivated')
            bot.api.send_message(chat_id: $tgGroupID, text: "Lagne automatiche attivate 😊")
          else
            out_file = File.new($botPath + ".deactivated", "w")
            out_file.puts(Time.now)
            out_file.close
            bot.api.send_message(chat_id: $tgGroupID, text: "Lagne automatiche disattivate 😢")
          end
          puts "Comando Toggle -- Chat type: #{message.chat.type} ID: #{message.chat.id}"
        end
        if message.text =~ /\/coccole@#{$botName}/i
          bot.api.send_message(chat_id: $tgGroupID, text: "Per farmi coccolare qualcuno, scrivi semplicemente \"Mirtilla, coccola nome\", sostituendo \"nome\" con l'username (preceduto da @) o il nome di qualcuno.")
        end

        if message.text =~ /\AMirtilla, coccola /
          text[0,18]=""
          if text == ""
            bot.api.send_message(chat_id: $tgGroupID, text: "Non ho capito chi devo coccolare.")
          else
            arrayCuddles = ["ti abbraccio", "ti coccolo", "ti stringo forte", "ti do un bacino", "ti abbraccio forte", "ti do tanto affetto", "ti voglio bene"].sample
            arrayCuddles2 = ["spero che tutto si sistemi", "spero che le cose vadano meglio presto", "credo in te", "so che ce la puoi fare", "andrà tutto per il meglio", "spero che tu ti possa sentire meglio", "mi dispiace se stai male"].sample
            arrayCuddles3 = ["Forza", "Ho fiducia in te", "Vietato morire", "*Hagu*", "Sei cute", "Coraggio", "La vita è bella", "Sei un tesoro", "Non so cosa farei senza di te"].sample
            coccola = text + ", " + arrayCuddles + " e " + arrayCuddles2 + ". " + arrayCuddles3 + "!"
            bot.api.send_message(chat_id: $tgGroupID, text: coccola)
          end
        end

        if message.text =~ /\/oroscopo@#{$botName}/i
            puts "Richiesta di oroscopo da: #{message.from.username.to_s} con ID #{message.from.id}"
            bundleStars = (message.from.id.to_s + Date.today.to_s)
            introStars = "Ciao @" + message.from.username.to_s + "! Ora ti leggerò le stelle! 🌟\nDammi solo un istante."
            bot.api.send_message(chat_id: $tgGroupID, text: introStars)
            shaStars = Digest::SHA256.hexdigest(bundleStars)
            arrayStars = [shaStars[0..1].to_i(16), shaStars[2..3].to_i(16), shaStars[4..5].to_i(16)]
            arrayExcellents = ["Oggi è una giornata davvero bella dal punto di vista affettivo! Chissà, magari potrà succedere qualcosa di magico!", "È un giorno veramente fortunato per te! Speriamo che possa succedere qualcosa di bello!", "Quella di oggi dovrebbe essere una giornata all'insegna del successo professionale. Che bello!"]
            arrayGoods = ["Oggi è una bella giornata per i tuoi sentimenti. Nell'aria c'è qualcosa di buono, me lo sento!", "La fortuna ti dovrebbe arridere. Speriamo che sia davvero così!", "È una buona giornata dal punto di vista produttivo. Ti auguro buon lavoro!"]
            arrayMehs = ["Oggi è una giornata sentimentalmente tranquilla.", "Dal punto di vista della fortuna, sembra essere una giornata nella media.", "Oggi è una buona giornata per impegnarsi, ma cerca di non strafare!"]
            arrayBads = ["Oggi non è esattamente una bella giornata per avere dei contatti sociali. Meglio stare in casa.", "Oggi le stelle non sono ben allineate. La fortuna potrebbe non essere dalla tua parte.", "Oggi è una giornata complicata, ma ce la puoi fare!"]
            arrayTerribles = ["Oggi è proprio una giornata all'insegna del malumore. Mi dispiace.","È meglio che non tenti la tua fortuna oggi, perché non è per niente dalla tua parte.", "Oggi è proprio una giornata difficile. Mi raccomando, fai delle pause se non te la senti di fare le cose."]
            sleep(5)
            for i in 0..2
              case arrayStars[i]
                when 0..15
                  bot.api.send_message(chat_id: $tgGroupID, text: arrayTerribles[i])
                when 16..63
                  bot.api.send_message(chat_id: $tgGroupID, text: arrayBads[i])
                when 64..127
                  bot.api.send_message(chat_id: $tgGroupID, text: arrayMehs[i])
                when 128..191
                  bot.api.send_message(chat_id: $tgGroupID, text: arrayGoods[i])
                when 192..255
                  bot.api.send_message(chat_id: $tgGroupID, text: arrayExcellents[i])
              else
                bot.api.send_message(chat_id: $tgGroupID, text: "Si è verificato un errore. Non sono in grado di leggere le stelle.")
              end
            end
          end

        next
        
        # Here you can code more functions
      end
    end
  end
end

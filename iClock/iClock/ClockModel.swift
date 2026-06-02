import Foundation
import Combine

class ClockModel: ObservableObject {
    @Published var hours: String       = "00"
    @Published var minutes: String     = "00"
    @Published var seconds: String     = "00"
    @Published var dateString: String  = ""
    @Published var dailyPhrase: String = ""
    @Published var colonVisible: Bool  = true

    private var timer: AnyCancellable?
    private var langCancellable: AnyCancellable?
    private let calendar = Calendar.current
    private let fmt = DateFormatter()

    init() {
        update()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.update() }

        // Re-render immediately when the user switches language
        langCancellable = LanguageManager.shared.$language
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.update() }
    }

    private func update() {
        let lang = LanguageManager.shared.language
        fmt.locale = Locale(identifier: lang.localeId)

        let now = Date()
        fmt.dateFormat = "HH"; hours   = fmt.string(from: now)
        fmt.dateFormat = "mm"; minutes = fmt.string(from: now)
        fmt.dateFormat = "ss"; seconds = fmt.string(from: now)

        switch lang {
        case .portuguese:
            fmt.dateFormat = "EEEE, d 'de' MMMM 'de' yyyy"
        case .english:
            fmt.dateFormat = "EEEE, MMMM d, yyyy"
        }
        dateString = fmt.string(from: now)

        colonVisible.toggle()

        let phrase = phraseForToday(lang: lang)
        if phrase != dailyPhrase { dailyPhrase = phrase }
    }

    private func phraseForToday(lang: AppLanguage) -> String {
        let day = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        switch lang {
        case .portuguese:
            return Self.phrasesPT[(day - 1) % Self.phrasesPT.count]
        case .english:
            return Self.phrasesEN[(day - 1) % Self.phrasesEN.count]
        }
    }

    // MARK: - Frases em Português de Portugal

    private static let phrasesPT: [String] = [
        "Cada dia é uma nova oportunidade para seres a melhor versão de ti mesmo.",
        "O sucesso é a soma de pequenos esforços repetidos dia após dia.",
        "Acredita em ti mesmo e tudo será possível.",
        "A persistência realiza o impossível.",
        "Começa onde estás. Usa o que tens. Faz o que podes.",
        "A tua atitude determina a tua direção.",
        "Sonha grande, trabalha muito, mantém o foco.",
        "Cada amanhecer traz consigo novas possibilidades.",
        "O único limite és tu mesmo.",
        "Faz hoje o que outros não querem, para teres amanhã o que outros não têm.",
        "A coragem não é a ausência do medo, mas agir apesar dele.",
        "Pequenas ações diárias criam grandes resultados.",
        "Sê a mudança que queres ver no mundo.",
        "A vida começa no fim da tua zona de conforto.",
        "Nunca desistas dos teus sonhos.",
        "O caminho de mil milhas começa com um único passo.",
        "Acredita que podes e já estás a meio caminho.",
        "Trabalha em silêncio, deixa o teu sucesso fazer barulho.",
        "Hoje é o dia perfeito para fazeres algo extraordinário.",
        "A disciplina é a ponte entre os objetivos e as realizações.",
        "Não esperes pela oportunidade perfeita, cria-a.",
        "A gratidão transforma o que temos em suficiente.",
        "Sê teimoso nos teus objetivos e flexível nos teus métodos.",
        "O teu tempo é limitado, não o desperdices a viver a vida de outro.",
        "Cada erro é uma lição disfarçada.",
        "A força não vem de ganhar, vem de superar os desafios.",
        "Investe em ti mesmo, é o melhor investimento que podes fazer.",
        "A vida é curta para viveres com arrependimentos.",
        "Transforma os teus medos em motivação.",
        "O futuro pertence a quem acredita na beleza dos seus sonhos.",
        "Não contes os dias, faz os dias contarem.",
        "A tua energia vai para aquilo em que focuses a tua atenção.",
        "Sê grato pelo que tens enquanto trabalhas pelo que queres.",
        "Cada dia é uma segunda oportunidade.",
        "Os grandes realizadores são movidos pelo entusiasmo.",
        "Pensa positivo, age positivo, sê positivo.",
        "A determinação de hoje é a vitória de amanhã.",
        "Nunca subestimes o poder de um bom começo.",
        "Faz da tua vida uma história que vale a pena contar.",
        "Sorri, porque cada dia é um presente.",
        "O esforço de hoje é a recompensa de amanhã.",
        "Sê a luz que ilumina os outros.",
        "A consistência é a chave para o sucesso duradouro.",
        "Olha para a frente, o melhor ainda está para vir.",
        "Não há nada impossível para quem acredita.",
        "O segredo é começar. O resto vem com o caminho.",
        "Transforma os obstáculos em degraus para o sucesso.",
        "A vida recompensa a ação.",
        "Sê corajoso o suficiente para viveres a vida que imaginas.",
        "Um dia de cada vez, um passo de cada vez.",
        "A tua força interior é maior do que qualquer desafio.",
        "Escolhe todos os dias ser feliz.",
        "O progresso, não a perfeição, é o objetivo.",
        "Acorda com determinação, vai dormir com satisfação.",
        "Os melhores momentos da tua vida ainda estão por acontecer.",
        "Inspira outros com as tuas ações.",
        "Nunca pares de aprender, crescer e evoluir.",
        "A resiliência é a chave para superar qualquer adversidade.",
        "Faz do teu trabalho a tua paixão.",
        "O sucesso não é final, o fracasso não é fatal — o que conta é a coragem de continuar.",
        "Vive cada momento como se fosse o último.",
        "A mudança começa com uma decisão.",
        "Sê a melhor versão de ti mesmo todos os dias.",
        "A tua jornada é única, abraça-a.",
        "Pequenos passos levam a grandes destinos.",
        "Confia no processo, os resultados virão.",
        "Cada amanhecer é uma página em branco — escreve algo bonito.",
        "A vida é uma aventura — vive-a plenamente.",
        "O teu maior concorrente és tu mesmo de ontem.",
        "Sê paciente, as coisas boas levam tempo.",
        "A positividade é uma escolha — escolhe-a todos os dias.",
        "Aprecia o presente, é o maior presente que tens.",
        "Vai com tudo. Não há tempo para meias medidas.",
        "A tua atitude é o teu superpoder.",
        "Faz hoje melhor do que ontem.",
        "Nunca deixes que o medo de errar te impeça de tentar.",
        "O mundo está cheio de possibilidades — abraça-as.",
        "Levanta-te, brilha e faz a diferença.",
        "A tua vontade de vencer tem de ser maior do que o medo de falhar.",
        "Cada obstáculo é uma oportunidade disfarçada.",
        "Age como se o impossível fosse possível.",
        "O teu esforço hoje define o teu amanhã.",
        "Sê o herói da tua própria história.",
        "A motivação é o que te faz começar, o hábito é o que te faz continuar.",
        "Crê em ti mesmo com toda a tua força.",
        "A vida é bela — aprecia cada momento dela.",
        "Não deixes que os dias passem sem significado.",
        "A excelência não é um ato, é um hábito.",
        "Vai dormir com sonhos, acorda com propósito.",
        "Sê mais forte do que as tuas desculpas.",
        "O sucesso começa com a decisão de tentar.",
        "Faz sempre o teu melhor — o teu futuro agradecerá.",
        "A tua determinação é o teu destino.",
        "Abraça os desafios, eles tornam-te mais forte.",
        "Cada grande jornada começa com um primeiro passo.",
        "Sê extraordinário num mundo de ordinário.",
        "A tua grandeza está em ti — liberta-a.",
        "Hoje é um bom dia para ter um bom dia.",
        "O esforço sincero nunca falha.",
        "Sê apaixonado pelo que fazes e o sucesso seguirá.",
        "A vida é dez por cento o que te acontece e noventa por cento como respondes.",
        "Nunca subestimes o teu próprio potencial.",
        "Todos os dias é uma nova chance de mudar a tua vida.",
        "A tua energia define o teu mundo.",
        "Faz acontecer. Começa agora.",
        "O melhor investimento é aquele que fazes em ti mesmo.",
        "Sê aquele que nunca desiste.",
        "A garra supera o talento quando o talento não tem garra.",
        "Cada dia que passa és um dia mais sábio.",
        "Vai em frente — o teu destino está à tua espera.",
        "Transforma a tua dor em poder.",
        "Sê corajoso. Sê curioso. Sê tu mesmo.",
        "O teu potencial é ilimitado.",
        "Faz da tua vida algo que valha a pena lembrar.",
        "A gratidão é o primeiro passo para a abundância.",
        "Nunca pares de acreditar em ti mesmo.",
        "Cada minuto conta — usa-o bem.",
        "A tua história ainda não acabou. O melhor capítulo está a ser escrito agora.",
        "Sê imparável.",
        "A tua força está na tua fé em ti mesmo.",
        "O sucesso é uma jornada, não um destino.",
        "Sê aquilo que admiras nos outros.",
        "A vida é curta — vive-a com intensidade.",
        "Nunca deixes de sonhar grande.",
        "O teu amanhã depende do que fazes hoje.",
        "Acredita. Persiste. Conquista.",
        "Cada dia é uma vitória — celebra-o.",
        "Faz o bem e o bem voltará para ti.",
        "A tua missão é ser melhor do que eras ontem.",
        "Vai com confiança na direção dos teus sonhos.",
        "A vida premia os corajosos.",
        "Faz de hoje o teu melhor dia.",
        "A esperança é o combustível dos grandes feitos.",
        "O esforço silencioso cria resultados barulhentos.",
        "Acorda todos os dias com gratidão no coração.",
        "Sê a razão pela qual alguém sorri hoje.",
        "Vai mais longe do que pensas que consegues.",
        "Sê persistente — o mundo recompensa os que não desistem.",
        "A tua vida é uma obra de arte — pinta-a com cores vivas.",
        "Faz grandes coisas — começa agora.",
        "O bem que fazes hoje é o legado de amanhã.",
        "Vive com propósito, age com paixão.",
        "Sê a mudança. Faz a diferença. Deixa um legado.",
    ]

    // MARK: - Motivational phrases in English

    private static let phrasesEN: [String] = [
        "Every day is a new opportunity to become the best version of yourself.",
        "Success is the sum of small efforts repeated day in and day out.",
        "Believe in yourself and anything is possible.",
        "Persistence achieves the impossible.",
        "Start where you are. Use what you have. Do what you can.",
        "Your attitude determines your direction.",
        "Dream big, work hard, stay focused.",
        "Every sunrise brings new possibilities.",
        "The only limit is yourself.",
        "Do today what others won't, so tomorrow you can do what others can't.",
        "Courage is not the absence of fear, but acting in spite of it.",
        "Small daily actions create great results.",
        "Be the change you wish to see in the world.",
        "Life begins at the end of your comfort zone.",
        "Never give up on your dreams.",
        "A journey of a thousand miles begins with a single step.",
        "Believe you can and you're halfway there.",
        "Work in silence, let your success make the noise.",
        "Today is the perfect day to do something extraordinary.",
        "Discipline is the bridge between goals and accomplishment.",
        "Don't wait for the perfect opportunity — create it.",
        "Gratitude turns what we have into enough.",
        "Be stubborn about your goals and flexible about your methods.",
        "Your time is limited, don't waste it living someone else's life.",
        "Every mistake is a lesson in disguise.",
        "Strength doesn't come from winning, it comes from overcoming challenges.",
        "Invest in yourself — it's the best investment you can make.",
        "Life is too short to live with regrets.",
        "Turn your fears into motivation.",
        "The future belongs to those who believe in the beauty of their dreams.",
        "Don't count the days — make the days count.",
        "Your energy flows where your attention goes.",
        "Be grateful for what you have while working for what you want.",
        "Every day is a second chance.",
        "Great achievers are driven by enthusiasm.",
        "Think positive, act positive, be positive.",
        "Today's determination is tomorrow's victory.",
        "Never underestimate the power of a good beginning.",
        "Make your life a story worth telling.",
        "Smile, because every day is a gift.",
        "Today's effort is tomorrow's reward.",
        "Be the light that guides others.",
        "Consistency is the key to lasting success.",
        "Look ahead — the best is yet to come.",
        "Nothing is impossible for those who believe.",
        "The secret is to start. The rest comes with the journey.",
        "Turn obstacles into stepping stones to success.",
        "Life rewards action.",
        "Be brave enough to live the life you imagine.",
        "One day at a time, one step at a time.",
        "Your inner strength is greater than any challenge.",
        "Choose to be happy every day.",
        "Progress, not perfection, is the goal.",
        "Wake up with determination, go to sleep with satisfaction.",
        "The best moments of your life are still ahead.",
        "Inspire others through your actions.",
        "Never stop learning, growing, and evolving.",
        "Resilience is the key to overcoming any adversity.",
        "Make your work your passion.",
        "Success is not final, failure is not fatal — what counts is the courage to continue.",
        "Live every moment as if it were your last.",
        "Change begins with a decision.",
        "Be the best version of yourself every day.",
        "Your journey is unique — embrace it.",
        "Small steps lead to great destinations.",
        "Trust the process — results will follow.",
        "Every dawn is a blank page — write something beautiful.",
        "Life is an adventure — live it fully.",
        "Your biggest competitor is yesterday's you.",
        "Be patient — good things take time.",
        "Positivity is a choice — choose it every day.",
        "Appreciate the present — it is the greatest gift you have.",
        "Give it everything. There is no time for half measures.",
        "Your attitude is your superpower.",
        "Do better today than yesterday.",
        "Never let the fear of failure stop you from trying.",
        "The world is full of possibilities — embrace them.",
        "Rise, shine, and make a difference.",
        "Your will to win must be greater than your fear of failure.",
        "Every obstacle is an opportunity in disguise.",
        "Act as if the impossible were possible.",
        "Your effort today defines your tomorrow.",
        "Be the hero of your own story.",
        "Motivation gets you started; habit keeps you going.",
        "Believe in yourself with everything you have.",
        "Life is beautiful — appreciate every moment of it.",
        "Don't let the days pass without meaning.",
        "Excellence is not an act — it is a habit.",
        "Go to sleep with dreams, wake up with purpose.",
        "Be stronger than your excuses.",
        "Success begins with the decision to try.",
        "Always do your best — your future self will thank you.",
        "Your determination is your destiny.",
        "Embrace challenges — they make you stronger.",
        "Every great journey begins with a first step.",
        "Be extraordinary in an ordinary world.",
        "Your greatness is within you — set it free.",
        "Today is a good day to have a good day.",
        "Sincere effort never fails.",
        "Be passionate about what you do and success will follow.",
        "Life is ten percent what happens to you and ninety percent how you respond.",
        "Never underestimate your own potential.",
        "Every day is a new chance to change your life.",
        "Your energy defines your world.",
        "Make it happen. Start now.",
        "The best investment is the one you make in yourself.",
        "Be the one who never gives up.",
        "Grit beats talent when talent lacks grit.",
        "Every day that passes you are one day wiser.",
        "Keep going — your destiny is waiting.",
        "Transform your pain into power.",
        "Be brave. Be curious. Be yourself.",
        "Your potential is limitless.",
        "Make your life something worth remembering.",
        "Gratitude is the first step towards abundance.",
        "Never stop believing in yourself.",
        "Every minute counts — use it well.",
        "Your story isn't over yet. The best chapter is being written right now.",
        "Be unstoppable.",
        "Your strength lies in your faith in yourself.",
        "Success is a journey, not a destination.",
        "Be what you admire in others.",
        "Life is short — live it with intensity.",
        "Never stop dreaming big.",
        "Your tomorrow depends on what you do today.",
        "Believe. Persist. Conquer.",
        "Every day is a victory — celebrate it.",
        "Do good and good will come back to you.",
        "Your mission is to be better than you were yesterday.",
        "Go confidently in the direction of your dreams.",
        "Life rewards the courageous.",
        "Make today your best day.",
        "Hope is the fuel of great achievements.",
        "Silent effort creates loud results.",
        "Wake up every day with gratitude in your heart.",
        "Be the reason someone smiles today.",
        "Go further than you think you can.",
        "Be persistent — the world rewards those who don't give up.",
        "Your life is a work of art — paint it with vivid colours.",
        "Do great things — start now.",
        "The good you do today is tomorrow's legacy.",
        "Live with purpose, act with passion.",
        "Be the change. Make a difference. Leave a legacy.",
    ]
}

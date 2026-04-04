/// All words are exactly 5 letters.
class WordList {
  /// Answer words — finance, trading, crypto, and tokenized asset terms.
  static const List<String> answerWords = [
    // Crypto & Blockchain
    'token', 'block', 'chain', 'miner', 'stake', 'vault', 'smart', 'nonce',
    'peers', 'nodes', 'pools', 'whale', 'batch', 'burns', 'coins', 'ether',
    'forks', 'gains', 'halve', 'layer', 'proof', 'quant', 'relay', 'seeds',
    'tally', 'units', 'vests', 'mints', 'swaps', 'cross',
    // Trading & Markets
    'trade', 'yield', 'alpha', 'delta', 'chart', 'rally', 'bears', 'bulls',
    'short', 'longs', 'entry', 'limit', 'order', 'asset', 'bonds', 'forex',
    'hedge', 'index', 'price', 'quote', 'ratio', 'sigma', 'theta', 'trend',
    'value', 'gamma', 'scalp', 'calls', 'cover', 'close', 'opens', 'pivot',
    'scope', 'risks', 'depth',
    // Finance & Tokenized Assets
    'stock', 'share', 'trust', 'funds', 'rates', 'debit', 'loans', 'repos',
    'notes', 'basis', 'audit', 'float', 'floor', 'macro', 'model', 'offer',
    'pairs', 'paper', 'peaks', 'scale', 'match', 'merge', 'money', 'worth',
    'grade', 'fixed', 'draft', 'total', 'terms', 'track', 'valid', 'watch',
    'waves', 'bears', 'rally',
  ];

  /// Valid guess words — answer words + large set of common 5-letter English words.
  static const List<String> validGuesses = [
    ...answerWords,
    // A
    'about', 'above', 'abuse', 'acute', 'admit', 'adopt', 'adult', 'after',
    'again', 'agent', 'agree', 'ahead', 'aimed', 'alarm', 'alert', 'alike',
    'alive', 'alley', 'allow', 'alone', 'along', 'altar', 'alter', 'amber',
    'amend', 'angel', 'anger', 'angle', 'angry', 'annex', 'antic', 'anvil',
    'apple', 'apply', 'argue', 'arise', 'armor', 'arose', 'array', 'arrow',
    'asked', 'attic', 'avail', 'avoid', 'aware', 'awful',
    // B
    'badly', 'basic', 'beast', 'began', 'begin', 'below', 'bench', 'berry',
    'birth', 'blade', 'blame', 'bland', 'blaze', 'bleed', 'blend', 'bless',
    'bliss', 'blood', 'blown', 'boast', 'board', 'bonus', 'boost', 'booth',
    'brave', 'bread', 'break', 'breed', 'brick', 'brief', 'bring', 'brisk',
    'broke', 'brook', 'brown', 'brush', 'buddy', 'build', 'built', 'buyer',
    // C
    'cabin', 'cable', 'camel', 'candy', 'cargo', 'carry', 'catch', 'cause',
    'cease', 'cedar', 'chalk', 'cheap', 'check', 'cheek', 'chess', 'chief',
    'child', 'chose', 'civic', 'civil', 'claim', 'clash', 'class', 'clean',
    'clear', 'clerk', 'cliff', 'climb', 'cling', 'clone', 'cloud', 'clove',
    'coach', 'coast', 'color', 'combo', 'comes', 'comma', 'coral', 'count',
    'court', 'covet', 'crack', 'craft', 'crane', 'crash', 'crave', 'crawl',
    'crazy', 'creek', 'creep', 'crisp', 'crown', 'crude', 'cruel', 'crush',
    'cubic', 'curve', 'cycle',
    // D
    'daily', 'dance', 'dared', 'deals', 'decoy', 'delay', 'dense', 'depot',
    'debut', 'devil', 'dirty', 'disco', 'doing', 'doubt', 'dough', 'downs',
    'dozen', 'drama', 'drawn', 'dream', 'dress', 'dried', 'drink', 'drive',
    'drone', 'drove', 'drown', 'drunk', 'dryer', 'dying',
    // E
    'eager', 'eagle', 'earth', 'eight', 'elite', 'empty', 'ended', 'enemy',
    'enjoy', 'enter', 'equal', 'error', 'essay', 'every', 'exist', 'extra',
    'early', 'epoch', 'exact', 'event',
    // F
    'fable', 'faced', 'false', 'fancy', 'fatal', 'feast', 'fence', 'ferry',
    'fetch', 'fever', 'fewer', 'fifth', 'fifty', 'filed', 'first', 'flame',
    'flash', 'flesh', 'flier', 'fling', 'flood', 'flora', 'flour', 'fluid',
    'flute', 'focal', 'focus', 'foggy', 'force', 'forge', 'forth', 'found',
    'frame', 'franc', 'frank', 'fraud', 'fresh', 'front', 'froze', 'fully',
    'funny', 'fuzzy', 'faith', 'final',
    // G
    'ghost', 'given', 'gland', 'glare', 'glass', 'glide', 'gloom', 'glory',
    'glove', 'going', 'gorge', 'gouge', 'gourd', 'grail', 'grams', 'grind',
    'groan', 'grope', 'group', 'growl', 'grown', 'gruel', 'guide', 'guild',
    'guile', 'guise', 'gusts', 'grace', 'grant', 'gross', 'guess',
    // H
    'habit', 'harsh', 'haunt', 'haven', 'heart', 'heavy', 'hippo', 'hobby',
    'hotel', 'hound', 'house', 'human', 'humid', 'humor', 'hurry', 'hyper',
    'hoard', 'hopes',
    // I
    'ideal', 'imply', 'inbox', 'inner', 'intel', 'inter', 'intro', 'irony',
    'input', 'issue',
    // J
    'jumbo', 'joint', 'joins', 'joint',
    // K
    'keyed', 'kneel', 'knife', 'knots', 'keeps', 'kings', 'known', 'karma',
    // L
    'label', 'labor', 'lance', 'lapse', 'laser', 'laugh', 'lease', 'ledge',
    'libel', 'liken', 'liner', 'lingo', 'lions', 'liver', 'local', 'lodge',
    'logic', 'loose', 'lover', 'lowly', 'loyal', 'lucid', 'lunar', 'lying',
    'large', 'later', 'leads', 'learn', 'least', 'legal', 'lemon', 'level',
    'lifts', 'light', 'links', 'lists', 'lower', 'lucky',
    // M
    'magic', 'major', 'maker', 'manor', 'maple', 'march', 'mason', 'maybe',
    'media', 'mercy', 'merit', 'metal', 'meter', 'midst', 'might', 'miles',
    'mills', 'minus', 'mirth', 'mixed', 'moody', 'mouse', 'mouth', 'moved',
    'mover', 'movie', 'muddy', 'music', 'marks', 'means', 'month', 'moves',
    'multi', 'moral', 'macro',
    // N
    'naive', 'named', 'nasty', 'naval', 'nerve', 'newly', 'noise', 'north',
    'notch', 'nurse', 'needs', 'never', 'night', 'noted', 'novel',
    // O
    'occur', 'ocean', 'olive', 'onset', 'overt', 'oxide', 'ozone', 'often',
    'other', 'ought', 'outer', 'owned', 'owner',
    // P
    'pasta', 'pedal', 'penny', 'perch', 'perky', 'petty', 'phone', 'photo',
    'piano', 'piece', 'pilot', 'pinch', 'pitch', 'place', 'plead', 'pluck',
    'plumb', 'plume', 'plunk', 'plush', 'polar', 'poser', 'posed', 'pouch',
    'prawn', 'preen', 'prick', 'pride', 'prime', 'print', 'prism', 'privy',
    'prone', 'proud', 'prove', 'psalm', 'pulse', 'punch', 'pupil', 'purge',
    'pylon', 'parse', 'parts', 'patch', 'pause', 'phase', 'plain', 'plate',
    'plays', 'plaza', 'point', 'ports', 'power', 'prior', 'prize', 'probe',
    'proxy', 'pulls', 'pumps',
    // Q
    'quake', 'queen', 'quirk', 'quota', 'query', 'queue', 'quick', 'quiet',
    'quite',
    // R
    'rabbi', 'racer', 'radio', 'raise', 'rangy', 'raven', 'rebel', 'recut',
    'remit', 'remix', 'rerun', 'reuse', 'rhyme', 'rider', 'rifle', 'risky',
    'rivet', 'roast', 'robot', 'rocky', 'rodeo', 'rouge', 'royal', 'rugby',
    'ruler', 'rusty', 'radar', 'range', 'reach', 'reads', 'ready', 'realm',
    'refer', 'reset', 'rises', 'round', 'route', 'rules',
    // S
    'sadly', 'safer', 'saint', 'salve', 'salvo', 'sandy', 'sauce', 'savor',
    'savvy', 'scald', 'scamp', 'scant', 'scare', 'scary', 'scoff', 'scold',
    'scone', 'scoop', 'shack', 'shaft', 'shake', 'shale', 'shall', 'shame',
    'sharp', 'shear', 'sheen', 'sheer', 'shelf', 'shell', 'shine', 'shire',
    'shirt', 'shock', 'shore', 'shout', 'shred', 'shrub', 'shrug', 'sided',
    'siege', 'silky', 'silly', 'since', 'sinew', 'siren', 'skate', 'skull',
    'slant', 'sleet', 'slept', 'slick', 'slung', 'smack', 'smash', 'smear',
    'smell', 'smelt', 'smite', 'smoke', 'snack', 'snaky', 'snare', 'sneak',
    'snore', 'solar', 'sonar', 'sonic', 'south', 'spare', 'spark', 'spawn',
    'spear', 'speck', 'speed', 'spell', 'spice', 'spike', 'spill', 'spine',
    'spite', 'spoon', 'spore', 'sport', 'spout', 'spray', 'spree', 'sprig',
    'spunk', 'squad', 'squat', 'squid', 'staff', 'stain', 'stale', 'stall',
    'stamp', 'stand', 'stare', 'stark', 'stern', 'stiff', 'sting', 'stink',
    'stomp', 'stood', 'stoop', 'strap', 'straw', 'stray', 'strut', 'stuck',
    'stump', 'stung', 'stunk', 'stunt', 'sugar', 'sulky', 'sunny', 'surge',
    'swamp', 'swear', 'sweat', 'swept', 'swirl', 'swoon', 'swoop', 'scene',
    'score', 'sense', 'serve', 'shape', 'shift', 'skill', 'slack', 'slate',
    'sleep', 'slice', 'slide', 'slope', 'slows', 'small', 'smile', 'snaps',
    'solid', 'solve', 'sorts', 'sound', 'space', 'spend', 'split', 'spoke',
    'spots', 'stack', 'stage', 'start', 'state', 'stays', 'steps', 'stick',
    'still', 'store', 'storm', 'story', 'study', 'style', 'suite', 'super',
    'swift', 'swing', 'sends',
    // T
    'taboo', 'talon', 'tango', 'taunt', 'tense', 'tenth', 'tepid', 'terse',
    'timer', 'timid', 'tipsy', 'toast', 'tonal', 'topaz', 'torch', 'toxic',
    'trace', 'trans', 'trash', 'trial', 'tribe', 'trick', 'tried', 'troll',
    'troop', 'trout', 'truce', 'truly', 'trunk', 'tuber', 'tulip', 'tumor',
    'tutor', 'tweak', 'twerp', 'twill', 'twirl', 'twist', 'table', 'takes',
    'talks', 'tasks', 'teams', 'tests', 'their', 'there', 'these', 'thick',
    'thing', 'think', 'third', 'those', 'tight', 'times', 'tired', 'title',
    'today', 'tools', 'touch', 'tough', 'tours', 'towns', 'twice', 'types',
    // U
    'ultra', 'uncut', 'unfed', 'unfit', 'unity', 'unlit', 'unset', 'untie',
    'upset', 'urban', 'utter', 'under', 'union', 'until', 'upper', 'usage',
    'users', 'usual',
    // V
    'vapor', 'vaunt', 'vicar', 'vigor', 'villa', 'vinyl', 'viola', 'viral',
    'visit', 'visor', 'voice', 'voila', 'vouch', 'vowel', 'vying', 'venue',
    'views', 'vital', 'voted',
    // W
    'waged', 'wager', 'waist', 'waste', 'water', 'weary', 'weave', 'wedge',
    'woken', 'woman', 'women', 'woods', 'wrath', 'wrist', 'weeks', 'whole',
    'wider', 'width', 'words', 'works', 'world', 'worry', 'worse', 'write',
    'wrote',
    // Y-Z
    'yacht', 'yearn', 'yeast', 'young', 'yours', 'years', 'zonal', 'zones',
  ];

  static bool isValidGuess(String word) {
    return validGuesses.contains(word.toLowerCase());
  }

  static String randomAnswerWord() {
    final now = DateTime.now();
    final dayIndex = now.difference(DateTime(2026, 1, 1)).inDays;
    return answerWords[dayIndex % answerWords.length];
  }
}

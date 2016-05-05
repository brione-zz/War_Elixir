defmodule(Game) do

  def start do
    deck = Cards.shuffle(Cards.make_deck(:full))
    hand_size = length(deck)/2
    { h1, deck } = Cards.deal(deck, trunc(hand_size))
    player1 = spawn(__MODULE__, :player, [ h1 ])
    player2 = spawn(__MODULE__, :player, [ deck ])
    play_a_round([player1, player2], [], { 0, 0, 0 })
    :ok
  end

  def play_a_round(players, pot, {rounds, ties, multiple} ) do
    request_cards_from_players(players, pot)
    player_cards = receive_cards_from_players([])
    case evaluate_round_list(player_cards) do
      { :tie, new_pot } -> 
        consecutive = case length(pot) do
          0 -> 0
          _ -> 1
        end
        new_stats = { rounds+1, ties+1, multiple + consecutive }
        play_a_round(players, pot ++ new_pot, new_stats)
      { :win, pid, new_pot } ->
        send pid, { :receive_cards, pot ++ new_pot }
        play_a_round(players, [], { rounds+1, ties, multiple} )
      { :game_over, pid, new_pot } ->
        for p <- players, do: send p, { :result, pid, pot ++ new_pot }
        IO.puts("Rounds: #{rounds}, Ties: #{ties}, Consecutive: #{multiple}")
    end
  end

  def request_cards_from_players(players, []) do
    for p <- players, do: send p, { :send_cards, 1, self() }
  end
  def request_cards_from_players(players, _) do
    for p <- players, do: send p, { :send_cards, 3, self() }
  end

  def receive_cards_from_players(rounds) do
    receive do
      { :cards, cards, pid } ->
        rounds = [ { cards, pid } | rounds ]
        if (length(rounds) < 2) do
          receive_cards_from_players(rounds)
        else
          rounds
        end
    end    
  end

  def rank_hands([ha|_], [hb|_]) do
    Card.rank_value(ha) - Card.rank_value(hb) 
  end  

  def evaluate_round_list([{[], _}, {cards, pid}]) do
    { :game_over, pid, cards }
  end
  def evaluate_round_list([{cards, pid}, {[], _}]) do
    { :game_over, pid, cards }
  end
  def evaluate_round_list([{cardsa, pida}, {cardsb, pidb}]) do
    pot = cardsa ++ cardsb
    diff = rank_hands(cardsa, cardsb)
    cond do
      diff == 0 -> { :tie, pot }
      diff > 0 -> { :win, pida, pot }
      diff < 0 -> { :win, pidb, pot }
    end
  end

  def player(hand) do
    #IO.puts("#{ inspect self() } initial hand #{ inspect hand }")
    player_loop(hand, [])
  end

  def player_loop(hand, discards) do
    receive do
      { :send_cards, num, pid } ->
        { cards, new_hand } = Cards.deal(hand, num)
        left = num - length(cards)
        if left > 0 and length(discards) > 0 do
          #IO.puts("#{ inspect self() } shuffling")
          new_hand = Cards.shuffle(discards)
          discards = []
          { more, new_hand } = Cards.deal(new_hand, left)
          cards = cards ++ more
        end
        #IO.puts "#{inspect self()} sending #{ inspect cards}, new hand #{inspect new_hand}"
        send pid, { :cards, cards, self() }
        player_loop(new_hand, discards)
      { :receive_cards, cards } ->
        #IO.puts "#{inspect self()} new discards #{inspect discards++cards}"
        player_loop(hand, discards ++ cards)
      { :result, pid, pot }  ->
        if pid == self() do
          total = hand ++ discards ++ pot
          #IO.puts("#{inspect self()} wins with #{inspect total}")
        else
          total = hand ++ discards
          #IO.puts("#{inspect self()} loses #{inspect total}") 
        end     
        #IO.puts("#{ inspect self() } exiting")
    end
  end

end

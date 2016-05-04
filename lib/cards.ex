defmodule(Cards) do

  def make_deck(type \\ :full) do
    ranks = Card.ranks(type) 
    suits = Card.suits(type)
    for r <- ranks, s <- suits, do: %Card{ rank: r, suit: s } 
  end

  def shuffle(deck) do
    :random.seed(:erlang.timestamp)
    shuffle(deck, [])
  end

  defp shuffle([], shuffled) do
    shuffled
  end

  defp shuffle(deck, shuffled) do
    { leading, [ h | t ] } = Enum.split(deck, :random.uniform(length(deck))-1)
    shuffle(leading ++ t, [h | shuffled]) 
  end

  def sort_deck(deck) do
    Enum.sort(deck, &Card.compare_cards/2)
  end

  def deal_bridge_hands do
    make_deck
    |> shuffle
    |> deal_bridge_hands({ [[],[],[],[]], 0 })
    |> Enum.map(&sort_deck/1)
  end

  defp deal_bridge_hands([], { hands, _index} ) do
    hands
  end

  defp deal_bridge_hands([card | deck], { hands, index } ) do
    new_hand = [ card | Enum.at(hands, index) ]
    new_hands = List.replace_at(hands, index, new_hand)
    new_index = case index do
      3 -> 0
      _ -> index + 1
    end
    deal_bridge_hands(deck, { new_hands, new_index })
  end


  def empty_hands(num) do
    for _ <- 1..num, do: []
  end

  @doc """
  Pull the top num_cards cards from deck and return list of cards and the new
  deck via a tuple like so { cards_list, new_deck }
  """
  def deal(deck, num_cards) do
    Enum.split(deck, num_cards)
  end

  def push_card(card, stack) do
    [ card | stack ]
  end

  def draw_card([]) do
    { :error, [] }
  end

  def draw_card([h | rest]) do
    { h, rest }    
  end
end

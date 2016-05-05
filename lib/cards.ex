defmodule(Cards) do

  @spec make_deck(:atom) :: list(%Card{})
  @doc """
  Return a new deck of standard %Card{} structures, like a poker or standard
  deck. If you pass any atom besides `:full` as the parameter, you will get
  the test deck.
  """
  def make_deck(type \\ :full) do
    ranks = Card.ranks(type) 
    suits = Card.suits(type)
    for r <- ranks, s <- suits, do: %Card{ rank: r, suit: s } 
  end

  @spec shuffle(list(%Card{})) :: list(%Card{})
  @doc """
  Randomize the order of the list of %Card{} structures and return the new
  list.
  """
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

  @spec sort_deck(list(%Card{})) :: list(%Card{})
  @doc """
  Sort the supplied deck according to the sort rule in Card.compare_cards()
  and return the sorted list.
  """
  def sort_deck(deck) do
    Enum.sort(deck, &Card.compare_cards/2)
  end

  @spec deal_bridge_hands() :: list()
  @doc """
  Generate a lists of four lists of thirteen randomized cards from a standard
  deck, like that used for a game of Bridge.
  """
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

  @spec push_card(%Card{}, list(%Card{})) :: list(%Card{})
  @doc """
  Push the supplied card to the top of the list and return the new list.
  """
  def push_card(card, stack) do
    [ card | stack ]
  end

  @spec draw_card(list(%Card{})) :: {%Card{}, list(%Card{})}
  @doc """
  Draw the top card from the list and return it along with the new list, in a
  tuple, or {:error, []} if drawing from an empty list/deck. 
  """
  def draw_card([]) do
    { :error, [] }
  end

  def draw_card([h | rest]) do
    { h, rest }    
  end
end

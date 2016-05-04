defmodule(Card) do
  @moduledoc """
  This module is supposed to represent a standard playing card.

  ## Examples
      iex> card = %Card{ rank: :q, suit: :hearts }

  """

  defstruct rank: :none, suit: :none

  defimpl Inspect, for: Card do
    import Inspect.Algebra

    def inspect(card, opts) do
      to_doc(to_string(card), opts)
    end
  end

  defimpl String.Chars, for: Card do

    def to_string(%Card{rank: r, suit: s}) do
      Card.rank_to_string(r)<> Card.suit_to_string(s)
    end
  end

  @spec suit_to_string(:atom) :: String.t
  @doc """
  Turn the suit atom into the UTF-8 representation of the suit
  """
  def suit_to_string(:hearts), do: <<0xe2,0x99,0xa5,0xef,0xb8,0x8f>>
  def suit_to_string(:diamonds), do: <<0xe2,0x99,0xa6,0xef,0xb8,0x8f>>
  def suit_to_string(:clubs), do: <<0xe2,0x99,0xa3,0xef,0xb8,0x8f>>
  def suit_to_string(:spades), do: <<0xe2,0x99,0xa0,0xef,0xb8,0x8f>>

  @spec rank_to_string(:atom) :: String.t
  @doc """
  Turn the rank atom into the UTF-8 representation of the suit
  """
  def rank_to_string(:a) do
    "A"
  end

  def rank_to_string(:k) do
    "K"
  end

  def rank_to_string(:q) do
    "Q"
  end

  def rank_to_string(:j) do
    "J"
  end

  def rank_to_string(r) do
    to_string(r)
  end

  @spec suits(:atom) :: list(:atom)
  @doc """
  Return a list of the suit atoms from a standard card deck.

  If this were real, and we were supporting multiple kinds of decks,
  we'd want to make a protocol. Maybe we still do.
  """
  def suits(type \\ :full) do
    if type == :full do
      [:hearts, :spades, :diamonds, :clubs]
    else
      [:hearts, :spades, :diamonds, :clubs]
    end
  end

  @spec suits(:atom) :: list(:atom)
  @doc """
  Return a list of the rank atoms of a standard poker card deck.
  """
  def ranks(type \\ :full) do
    if type == :full do
      [:a, :k, :q, :j, :"10", :"9", :"8", :"7", :"6", :"5", :"4", :"3", :"2"]
    else
      [:a, :k, :q, :j ]
    end 
  end

  @spec compare_cards(%Card{}, %Card{}) :: integer
  @doc """
  Return an integer value resulting from calculating the difference of
  card1 and card2, based on their card values.

  Returns: < 0 - card1 is less than card2
           == 0 - the cards are the same
           > 0 - card1 is greater than card2
  """
  def compare_cards(c1, c2) do
    card_value(c1) >= card_value(c2)
  end

  @spec suit_value(%Card{}) :: integer
  @doc """
  Return an integer based on the suit, such that it can be combined with
  rank_value (as is done in card_value) to receive a unique value for each
  card.
  """
  def suit_value(%Card{suit: :hearts}), do: 400
  def suit_value(%Card{suit: :spades}), do: 300
  def suit_value(%Card{suit: :diamonds}), do: 200
  def suit_value(%Card{suit: :clubs}), do: 100

  @spec rank_value(%Card{}) :: integer
  @doc """
  Return an integer based on the rank, such that it can be combined with
  suit_value (as is done in card_value) to receive a unique value for each
  card.
  """
  def rank_value(%Card{rank: :a}) do
    14
  end

  def rank_value(%Card{rank: :k}) do
    13
  end

  def rank_value(%Card{rank: :q}) do
    12
  end

  def rank_value(%Card{rank: :j}) do
    11
  end

  def rank_value(%Card{rank: r}) do
    { val, "" } = Integer.parse(to_string(r))
    val
  end

  @spec card_value(%Card{}) :: integer
  @doc """
  Return the total value of the given card received by combining the
  rank_value with the suit_value.
  """
  def card_value(card) do
    suit_value(card) + rank_value(card)
  end

end

defmodule Poker do
	def deal(shuf) do
		hand1 = List.delete_at(List.delete_at(shuf, 1), 2)
		hand2 = List.delete_at(List.delete_at(shuf, 0), 1)
		hand1 = royalFlush(hand1)
		hand2 = royalFlush(hand2)
		finalHand(hand1,hand2)
	end

	def finalHand(hand1,hand2) do
		y = Enum.at(hand2,1)
		case Enum.at(hand1,1) do
			x when x > y ->
				finalSuit([], Enum.at(hand1,0))
			x when x < y ->
				finalSuit([], Enum.at(hand2,0))
			x when x == y ->
				a = tieBreaker(Enum.at(hand1,0))
				b = tieBreaker(Enum.at(hand2,0))
				if a==1 do
					finalSuit([], Enum.at(hand1,0))
				else
					if b == 1 do
						finalSuit([], Enum.at(hand2,0))
					else
						if a == 13 do
							finalSuit([], Enum.at(hand1,0))
						else
							if b == 13 do
								finalSuit([], Enum.at(hand2,0))
							else
								if a>b do
									finalSuit([], Enum.at(hand1,0))
								else
									finalSuit([], Enum.at(hand2,0))
								end
							end
						end
					end
				end
		end
	end

	def tieBreaker(hand) do
		if (Enum.member?(hand, 1))||(Enum.member?(hand, 14))||(Enum.member?(hand, 27))||(Enum.member?(hand, 40)) do
			1
		else
			if (Enum.member?(hand, 13))||(Enum.member?(hand, 26))||(Enum.member?(hand, 39))||(Enum.member?(hand, 52)) do
				13
			else
				hand = Enum.map(hand,fn x-> rem(x,13) end)
				hd hand

			end
		end
	end

	def finalSuit(result, []) do
		result
	end
	def finalSuit(result, hand) do
		suits =
			[
				"1C", "2C", "3C", "4C", "5C", "6C", "7C", "8C", "9C", "10C", "11C", "12C", "13C",
				"1D", "2D", "3D", "4D", "5D", "6D", "7D", "8D", "9D", "10D", "11D", "12D", "13D",
				"1H", "2H", "3H", "4H", "5H", "6H", "7H", "8H", "9H", "10H", "11H", "12H", "13H",
				"1S", "2S", "3S", "4S", "5S", "6S", "7S", "8S", "9S", "10S", "11S", "12S", "13S"
			]
			temp = result ++ [Enum.at(suits, (hd hand)-1)]
			finalSuit(temp, (tl hand))
	end

	#--------------------------------------------------------------------------------------------------
	def royalFlush(hand) do
		cond do
			(Enum.member?(hand, 1) && Enum.member?(hand, 10) && Enum.member?(hand, 11) && Enum.member?(hand, 12) && Enum.member?(hand, 13)) ->
			[[1,10,11,12,13]] ++ [10]
			(Enum.member?(hand, 14) && Enum.member?(hand, 23) && Enum.member?(hand, 24) && Enum.member?(hand, 25) && Enum.member?(hand, 26)) ->
			[[14,23,24,25,26]] ++ [10]
			(Enum.member?(hand, 27) && Enum.member?(hand, 36) && Enum.member?(hand, 37) && Enum.member?(hand, 38) && Enum.member?(hand, 39)) ->
			[[27,36,37,38,39]] ++ [10]
			(Enum.member?(hand, 40) && Enum.member?(hand, 49) && Enum.member?(hand, 50) && Enum.member?(hand, 51) && Enum.member?(hand, 52)) ->
			[[40,49,50,51,52]] ++ [10]
			true ->
			straightFlush(hand)
		end
	end

	#--------------------------------------------------------------------------------------------------
	def straightFlush(hand) do
		hand = Enum.sort(hand, :desc)
		straightFlush(hand, hand,[],0)
	end
	def straightFlush(_oghand, hand,newhand,3) do
			[newhand ++ [(hd hand)]++ [(hd tl hand)]]++[9]
	end
	def straightFlush(oghand,[], _, _) do
		fourKind(oghand)
	end
	def straightFlush(oghand, hand,newhand,n) do
		cond do
				(Enum.at(hand,0)-1)==(Enum.at(hand,1))
				 -> straightFlush(oghand, (tl hand),newhand ++ [(hd hand)],n+1)
				true -> straightFlush(oghand, (tl hand),[],0)
		end
	end

	#--------------------------------------------------------------------------------------------------
	def fourKind(hand) do
		temp = Enum.map(hand, fn x -> rem(x,13) end)  |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
		temp = Map.new(temp, fn {key, val} -> {val, key} end)
		if (Map.has_key?(temp,4)) do
			[Enum.filter(hand, fn x -> rem(x, 13) == Map.get(temp,4) end)]++[8]
		else
			fullHouse(hand)
		end
	end

	#--------------------------------------------------------------------------------------------------
	def fullHouse(hand) do
			temp = Enum.map(hand, fn x -> rem(x,13) end)  |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
			temp = Map.new(temp, fn {key, val} -> {val, key} end)
			if (Map.has_key?(temp,3)) && (Map.has_key?(temp,2)) do
				temp1 = Enum.filter(hand, fn x -> rem(x, 13) == Map.get(temp,3) end)
				temp2 = Enum.filter(hand, fn x -> rem(x, 13) == Map.get(temp,2) end)
				[Enum.concat(temp1,temp2)]++[7]
			else
				flush(hand)
			end
	end

	#--------------------------------------------------------------------------------------------------
	def flush(hand) do
		flushClubs(hand)
	end
	def flushClubs(hand) do
		if Enum.count(Enum.filter(hand, fn x -> x>=1 && x<=13 end))==5 do
			hand = Enum.filter(hand, fn x -> x>=1 && x<=13 end)
			flushReturn(hand)
		else
			flushDiamonds(hand)
		end
	end
	def flushDiamonds(hand) do
		if Enum.count(Enum.filter(hand, fn x -> x>=14 && x<=26 end))==5 do
			hand = Enum.filter(hand, fn x -> x>=14 && x<=26 end)
			flushReturn(hand)
		else
			flushHearts(hand)
		end
	end
	def flushHearts(hand) do
		if Enum.count(Enum.filter(hand, fn x -> x>=27 && x<=39 end))==5 do
			hand = Enum.filter(hand, fn x -> x>=27 && x<=39 end)
			flushReturn(hand)
		else
			flushSpades(hand)
		end
	end
	def flushSpades(hand) do
		if Enum.count(Enum.filter(hand, fn x -> x>=40 && x<=52 end))==5 do
			hand = Enum.filter(hand, fn x -> x>=40 && x<=52 end)
			flushReturn(hand)
		else
			straight(hand)
		end
	end
	def flushReturn(hand) do
				[hand] ++ [6]
	end

	#--------------------------------------------------------------------------------------------------
	def straightConverter(hand, map,finalhand) do
		if (Enum.count(finalhand) != 5 ) do
			straightConverter((tl hand),map,finalhand ++ [Map.get(map, (hd hand))])
		else
			[finalhand]++[5]
		end
	end
	def straight(hand) do
		temp = hand ++ hand
		temp = Enum.sort(temp, :desc)
		temp2 = temp
			|> Enum.chunk_every(2)
			|> Enum.map(fn [a, b] -> {a, b} end)
			|> Map.new(fn {key, val} -> {val, key} end)

		temp = Enum.map(temp2, fn {k,v} -> {k,rem(v,13)} end)
		temp = Enum.into(temp, %{})
		temp = Map.replace(temp, 13, 13)
		temp = Map.replace(temp, 26, 13)
		temp = Map.replace(temp, 39, 13)
		temp = Map.replace(temp, 52, 13)
		temp2 = Enum.map(temp, fn {k,v} -> {v,k} end)

		temp2 = Enum.into(temp2, %{})
		straight(hand, Enum.uniq(Enum.sort(Map.values(temp), :desc)),[],0,temp2)
	end
	def straight(_oghand, hand,newhand,4,map) do
		straightConverter(newhand ++ [(hd hand)],map,[])
	end
	def straight(oghand,[], _, _,_) do
		threeKind(oghand)
	end
	def straight(oghand,hand,newhand,n,map) do
		cond do
				(Enum.member?(hand, 1) && Enum.member?(hand, 10) && Enum.member?(hand, 11) && Enum.member?(hand, 12) && Enum.member?(hand, 13))
				-> straightConverter([1,10,11,12,13],map,[])
				(Enum.at(hand,0)-1)==(Enum.at(hand,1))
				 -> straight(oghand, (tl hand),newhand ++ [(hd hand)],n+1,map)
				true -> straight(oghand, (tl hand),[],0,map)
		end
	end

	#--------------------------------------------------------------------------------------------------
	def threeKind(hand) do
		temp = Enum.map(hand, fn x -> rem(x,13) end)  |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
		temp = Map.new(temp, fn {key, val} -> {val, key} end)
		if (Map.has_key?(temp,3)) do
			[Enum.filter(hand, fn x -> rem(x, 13) == Map.get(temp,3) end)]++[4]
		else
			twoPair(hand)
		end
	end

	#--------------------------------------------------------------------------------------------------
	def twoPair(hand) do
		twoPair(hand, hand,[],0)
	end
	def twoPair(_,_,bothpair,2) do
		[bothpair] ++ [3]
	end
	def twoPair(oghand, hand, bothpairs,n) do
		temp = Enum.map(hand, fn x -> rem(x,13) end)  |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
		temp = Map.new(temp, fn {key, val} -> {val, key} end)
		flattened=List.flatten(bothpairs++[Enum.filter(hand, fn x -> rem(x, 13) == Map.get(temp,2) end)])
		if (Map.has_key?(temp,2)) do
			twoPair(oghand,hand--flattened,flattened,n+1)
		else
			pair(oghand)
		end
	end

	#--------------------------------------------------------------------------------------------------
	def pair(hand) do
		temp = Enum.map(hand, fn x -> rem(x,13) end)  |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
		temp = Map.new(temp, fn {key, val} -> {val, key} end)
		if (Map.has_key?(temp,2)) do
			[Enum.filter(hand, fn x -> rem(x, 13) == Map.get(temp,2) end)]++[2]
		else
			highCard(hand)
		end
	end

	#--------------------------------------------------------------------------------------------------
	def highCard(hand) do
		if (Enum.member?(hand, 1))||(Enum.member?(hand, 14))||(Enum.member?(hand, 27))||(Enum.member?(hand, 40)) do
			cond do
				(Enum.member?(hand, 1))  ->
					[[1]] ++ [1]
				(Enum.member?(hand, 14))  ->
					[[14]] ++ [1]
				(Enum.member?(hand, 27))  ->
					[[27]] ++ [1]
				(Enum.member?(hand, 40))  ->
					[[40]] ++ [1]
			end
		else
			if (Enum.member?(hand, 13))||(Enum.member?(hand, 26))||(Enum.member?(hand, 39))||(Enum.member?(hand, 52)) do
				cond do
					(Enum.member?(hand, 13))  ->
						[[13]] ++ [1]
					(Enum.member?(hand, 26))  ->
						[[26]] ++ [1]
					(Enum.member?(hand, 39))  ->
						[[39]] ++ [1]
					(Enum.member?(hand, 52))  ->
						[[52]] ++ [1]
				end
			else
				[[Enum.max_by(hand, fn x -> rem(x,13) end)]]++[1]
			end
		end
	end
end

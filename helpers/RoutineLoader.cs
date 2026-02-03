using Godot;
using RailRush.actions.dtos;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;

public partial class RoutineLoader : Node
{
	const string _routineDir = "res://routines/";
	const string FILE_EXTENSION = ".json";

	public void Test1()
	{
		Console.WriteLine("Hey");
	}
	
	public void Test2(string test)
	{
		Console.WriteLine("Hello: "+test);
	}

	public Godot.Collections.Array Load(string name)
	{
		var filePath = _routineDir + name + FILE_EXTENSION;
		GD.Print($"Loading routine: '{name}'\nSeeking at path: {filePath}'");
		string contentAsString;
		using (var file = FileAccess.Open(filePath, FileAccess.ModeFlags.Read))
		{
			GD.Print($"FILE {file}");
			contentAsString = file.GetAsText();
			GD.Print($"Loading fileContents: '{contentAsString}'");
		}
		var dataArray = JsonSerializer.Deserialize<List<ActionData>>(contentAsString);
		GodotObject[] contentArray = dataArray.Select(x => x.ToAction()).ToArray();
		return new Godot.Collections.Array(contentArray);
	}

	public void Write(string name, Godot.Collections.Array routine)
	{
		string serializedContent;
		try 
		{
			// Here the current actions will need to be converted into their data form
			List<ActionData> routineData = new();
			foreach (Action act in routine)
			{
				GD.Print("Iterating over routine");
				routineData.Add(act.Data);
			}
			GD.Print("Serialising routineData");
			serializedContent = JsonSerializer.Serialize(routineData);
			GD.Print($"Hey Look I Made You Some Content: {serializedContent}");
		}
		catch(Exception e)
		{
			GD.Print($"Encountered exception while trying to serialize! {e.Message}; My routine is {routine}");
			throw e;
		}
		var filePath = _routineDir + name + FILE_EXTENSION;
		using (var file = FileAccess.Open(filePath, FileAccess.ModeFlags.Write))
		{
			file.StoreString(serializedContent);
			GD.Print($"Saving file {name} at {filePath}");
		}
	}
}

use std::io::{BufReader, Read};
use std::{env, fs::File};
use xmltree::Element;

#[derive(Debug)]
struct MavlinkEnumDefinition {
    name: String,
    description: Option<String>,
    entries: Vec<MavlinkEnumEntryDefinition>
}

#[derive(Debug)]
struct MavlinkEnumEntryDefinition {
    name: String,
    value: u64,
    description: Option<String>,
}

#[derive(Debug)]
struct MavlinkMessageFieldDefinition {
    field_type: String,
    name: String,
    units: Option<String>,
    description: String,
}

#[derive(Debug)]
struct MavlinkMessageDefinition {
    description: Option<String>,
    name: String,
    id: u32, // actually a u24 in the packet format
    fields: Vec<MavlinkMessageFieldDefinition>,
}

#[derive(Default, Debug)]
struct MavlinkDefinitions {
    enums: Vec<MavlinkEnumDefinition>,
    msgs: Vec<MavlinkMessageDefinition>,
}

fn parse_definitions(mavlink_element: Element) -> MavlinkDefinitions {
    let mut defs = MavlinkDefinitions::default();

    let e_enums = mavlink_element.get_child("enums").unwrap();
    let e_msgs = mavlink_element.get_child("messages").unwrap();

    // Parse enums
    for enum_def in &e_enums.children {
        let enum_def = enum_def.as_element().unwrap();

        let description = enum_def
            .children
            .iter()
            .find(|&c| c.as_element().unwrap().name == "description")
            .and_then(|x| x.as_element())
            .and_then(|x| Some(&x.children[0]))
            .and_then(|x| x.as_text())
            .and_then(|x| Some(x.to_string()));

        let mut entries = Vec::new();

        for entry in &enum_def.children {
            let entry = entry.as_element().unwrap();
            if entry.name == "entry" {
                entries.push(MavlinkEnumEntryDefinition {
                    description: entry.children.get(0).and_then(|x| Some(x.as_text().unwrap().to_string())),
                    name: entry.attributes.get("name").unwrap().to_string(),
                    value: entry.attributes.get("value").unwrap().parse().unwrap()
                })
            }
        }

        defs.enums.push(MavlinkEnumDefinition {
            name: enum_def.attributes.get("name").unwrap().to_string(),
            description,
            entries,
        });
    }

    // Parse message definitions
    for msg_def in &e_msgs.children {
        let msg_def = msg_def.as_element().unwrap();

        let mut fields = Vec::new();

        for field in &msg_def.children {
            let field = field.as_element().unwrap();
            if field.name == "field" {
                fields.push(MavlinkMessageFieldDefinition {
                    description: field.children[0].as_text().unwrap().to_string(),
                    field_type: field.attributes.get("type").unwrap().to_string(),
                    name: field.attributes.get("name").unwrap().to_string(),
                    units: field.attributes.get("units").and_then(|x| Some(x.to_string()))
                })
            }
        }

        let mut description = None;

        if let Some(d) = msg_def
            .children
            .iter()
            .find(|&c| c.as_element().unwrap().name == "description")
        {
            description = Some(
                d.as_element().unwrap().children[0]
                    .as_text()
                    .unwrap()
                    .to_string(),
            )
        }

        defs.msgs.push(MavlinkMessageDefinition {
            id: msg_def.attributes.get("id").unwrap().parse().unwrap(),
            name: msg_def.attributes.get("name").unwrap().to_string(),
            description,
            fields,
        });
    }

    defs
}

fn main() -> std::io::Result<()> {
    let args: Vec<String> = env::args().collect();
    let file = File::open(args[1].clone())?;
    let mavlink_element = Element::parse(file).unwrap();

    let defs = parse_definitions(mavlink_element);
    println!("{:#?}", defs);

    Ok(())
}
